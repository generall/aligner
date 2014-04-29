#gem install bsearch
#gem install rubytree

require 'bsearch'
require 'set'
require 'tree'


def levenshtein(first, second)
  matrix = [(0..first.length).to_a]
  (1..second.length).each do |j|
    matrix << [j] + [0] * (first.length)
  end
 
  (1..second.length).each do |i|
    (1..first.length).each do |j|
      if first[j-1] == second[i-1]
        matrix[i][j] = matrix[i-1][j-1]
      else
        matrix[i][j] = [
          matrix[i-1][j],
          matrix[i][j-1],
          matrix[i-1][j-1],
        ].min + 1
      end
    end
  end
  return matrix.last.last
end

class Token
	attr_accessor :type, :value, :min_simularity, :necessary
	def initialize(value, type, necessary, min_simularity)
		@type = type;
		@value = value;
		@necessary = necessary;
		@min_simularity = min_simularity;
	end

	def cmp(other_token)
		if(@type != other_token.type) then
			return 0;
		else
			max_len = [@value.size, other_token.value.size].max
			return 1.0 - levenshtein(@value, other_token.value).to_f / max_len + other_token.min_simularity;
		end
	end
end

def check_prefix_tree(tree, list, sum, start)
	i = start;
    to_be_considered = true;
	is_in_tree = true;
	search_mod = true;
	
	# Варианты действий при обходе дерева
	# Режим поиска:
	# 	 1. Конец дерева не достигнут, конец списка не достигнут.
	# 		 перейти в след. узел
	# 	 2. Конец дерева не достигнут (нет информации о конце), конец списка дотигнут
	# 		 Обозначить узел как конечный, записать в него текущую сумму.
	# 	 3. Конец дерева достигнут, конец списка не достигнут
	# 		 Переключиться в режим добавления, добавить текущую вершину.
	# 	 4. Конец дерева достигнут, конец списка достигнут
	# 		 Существуют одинаковые списки. Сравнить content и sum 
	# 		 	sum >  content => записать в content = sum; продолжить генерацию пар
	# 			sum <= content => завершить эту линию вычислений.
	# Режим вставки:
	# 	1. Конец списка не достигнут
	# 		вставить текущуй индекс
	# 	2. Рассматриваемый индекс - последний.
	# 		Добавить индекс, добавить sum
	#
	#
 	curr_den_tree = tree

 	# empty set handeling
 	if start > list.size-1 then
		if curr_den_tree.content.size == 0 then
			curr_den_tree.content = [sum];
			to_be_considered = true;
		else
			prev_sum = curr_den_tree.content[0];
			if prev_sum >= sum then
				to_be_considered = false;
			else
				to_be_considered = true;
				curr_den_tree.content = [sum];
			end
		end
		return to_be_considered;
 	end

	for j in start..list.size-1 do
		pair_num = list[j]
		if search_mod then
			if list.size-1 == i then
				# End of the list is reached.
				if curr_den_tree[[pair_num]].nil? then
					# there is NO such element in tree
					curr_den_tree << Tree::TreeNode.new([pair_num],[sum]);
					curr_den_tree = curr_den_tree[[pair_num]];
					is_in_tree = false;
					to_be_considered = true;
				else
					# there is such element in tree
					curr_den_tree = curr_den_tree[[pair_num]];
					if curr_den_tree.content.size == 0 then
						# but it`s not final
						curr_den_tree.content = [sum];
						is_in_tree = false;
						to_be_considered = true;
					else
						# and it`s final
						prev_sum = curr_den_tree.content[0];
						if prev_sum >= sum then
							to_be_considered = false;
						else
							to_be_considered = true;
							curr_den_tree.content = [sum];
						end
					end
				end
			else
				# End of the list is not reached
				if curr_den_tree[[pair_num]].nil? then
					# End of the tree is reached
					curr_den_tree << Tree::TreeNode.new([pair_num],[]);
					curr_den_tree = curr_den_tree[[pair_num]];
					is_in_tree = false;
					to_be_considered = true;
					search_mod = false;
				else
					curr_den_tree = curr_den_tree[[pair_num]];
				end
			end
		else
			# add mode
			if list.size-1 == i then
				curr_den_tree << Tree::TreeNode.new([pair_num],[sum]);
			else
				curr_den_tree << Tree::TreeNode.new([pair_num],[]);
				curr_den_tree = curr_den_tree[[pair_num]];
			end
		end
		i+=1;					
	end

	return to_be_considered;
end


class Matcher

	def initialize(token_array1, token_array2)
		@token_arrays = [];
		@token_arrays += [token_array1];
		@token_arrays += [token_array2];
	end

	# Delete tokens, wich marked as insignificant + reorded arrays by size
	def erase_insignificant_tokens
		k = 0;
		while k < @token_arrays.size do
			i = 0;
			while i < @token_arrays[k].size do
				if @token_arrays[k][i].necessary == false then
					 @token_arrays[k].delete_at(i);
					 i -=1;
				end
				i+=1;
			end
			k+=1;
		end

		@min_size_array        = @token_arrays[0].size > @token_arrays[1].size ? @token_arrays[1] : @token_arrays[0];
		@max_size_array        = @token_arrays[0].size > @token_arrays[1].size ? @token_arrays[0] : @token_arrays[1];
		
		@min_size_array_index  = @token_arrays[0].size > @token_arrays[1].size ? 1 : 0;
		@max_size_array_index  = @token_arrays[0].size > @token_arrays[1].size ? 0 : 1;

		# p "min array:"
		# p @min_size_array
		# p @min_size_array.size
		# p "max array:"
		# p @max_size_array
		# p @max_size_array.size
	end

	# Generate all pairs of comparable tokens with it`s simularity in @pairs
	def generate_pairs(epsilon)
		@pairs = [];
		i = 0;
		@min_size_array.each do |token1|
			j = 0;
			@max_size_array.each do |token2|
				simularity = token1.cmp(token2);
				if simularity > epsilon then
					@pairs += [ [[i, j] , simularity] ];	
				end
				j+=1;
			end	
			i+=1;
		end
	end

	
	def get_intersection()

		@intersections = [];

		for i in 0..@pairs.size-2 do
			intersect = [i, []];
			for j in (i+1)..@pairs.size-1 do
				if @pairs[i][0][1] >= @pairs[j][0][1] || @pairs[i][0][0] == @pairs[j][0][0] then
					intersect[1] +=[j];
					#p  @pairs[i][0].to_s + " & " + @pairs[j][0].to_s;
				end
			end
			@intersections +=[intersect];
		end
		@intersections += [[@pairs.size-1, []]]
	end

	def get_reverse_intersection_lists()
		@reverse_intersections = {};
		@intersections.each do |intersection|
			if intersection[1].size > 0 then
				if (@reverse_intersections[intersection[1][-1]].nil?) then
					@reverse_intersections[intersection[1][-1]]  = [[intersection[0]] + intersection[1][0..-2]];
				else
					@reverse_intersections[intersection[1][-1]] += [[intersection[0]] + intersection[1][0..-2]];
				end
			end
		end
	end

	def optimize_reverse_intersection_lists
		#TODO make some optimizations here
	end

	def get_next_intersect_cluster(r)
		i = r.begin;
		while i <= r.last do
			if (@intersections[i][1].size > 0) then
				if (@intersections[i][1][-1] > r.last) then
					r = Range.new(r.begin, @intersections[i][1][-1])
				end
			end
			i+=1;
		end
		return r;
	end

	def get_intersection_clusters()
		@int_clusters = [];
		l = get_next_intersect_cluster((0..0));
		@int_clusters += [l];
		while (l.last < @intersections.size - 1) do@int_clusters
			l = get_next_intersect_cluster(((l.last+1)..(l.last+1)));
			@int_clusters += [l];
		end
		p @int_clusters;
	end

	#
	#
	# MAIN RECURRENT FUNCTION
	# 
	#
	def generate_combinations(set_of_pairs, accepted_pairs, denied_pairs, sum)
		if set_of_pairs.size == 0 then
			
			if @max_combination[@current_id][1] < sum then
				@max_combination[@current_id][0] = accepted_pairs;
				@max_combination[@current_id][1] = sum;
			end
			# p accepted_pairs
			#print "\t"
			#p sum;

		else
			pair_to_decide = set_of_pairs.min;

			current_intersections = @intersections[pair_to_decide][1] - denied_pairs;

			new_sum = sum + @pairs[pair_to_decide][1];

			curr_den_tree = @denied_list_cache[pair_to_decide];

			begin_index = denied_pairs.bsearch_upper_boundary {|x| x <=> pair_to_decide}

			to_be_considered = check_prefix_tree(curr_den_tree, denied_pairs, sum, begin_index);

			# p to_be_considered if pair_to_decide == 1;
			# p denied_pairs     if pair_to_decide == 1;
			# p begin_index      if pair_to_decide == 1;

			if not to_be_considered then
				return;
			end

			if current_intersections.size == 0 then
				set_for_next_iteration = set_of_pairs - [pair_to_decide];
				generate_combinations(set_for_next_iteration, accepted_pairs + [pair_to_decide], denied_pairs, new_sum);
			else
				# test both options
				
				# with current pair
				set_for_next_iteration = set_of_pairs - current_intersections - [pair_to_decide];
				generate_combinations(set_for_next_iteration, accepted_pairs + [pair_to_decide], denied_pairs + current_intersections, new_sum);
				# without current pair
				set_for_next_iteration = set_for_next_iteration + current_intersections;
				generate_combinations(set_for_next_iteration, accepted_pairs, denied_pairs + [pair_to_decide], sum);
			end
		end
	end


	# prepare for generation combinations
	def do_generate_combinations()
		i = 0;
		@denied_list_cache = (0..@pairs.size-1).map {|x| Tree::TreeNode.new("root", [])}
		@max_combination = [];
		@int_clusters.size.times {@max_combination += [[[],0]]};
		@int_clusters.each do |range|
			@current_id = i;
			set_of_pairs   = (range).map{|x| x};
			accepted_pairs = [];
			denied_pairs   = [];
			generate_combinations(set_of_pairs, accepted_pairs, denied_pairs, 0);
			i+=1;
		end
		p @max_combination;
	end

	def print_tokens
		k = 0;
		while k < @token_arrays.size do
			@token_arrays[k].each {|x| p x};
			p "---------";
			k+=1;
		end
	end

	def print_pairs
		i = 0;
		@pairs.each {|x| print i.to_s + ": "; p x; i+=1;}
	end


	def print_intersections
		p "---------";
		@intersections.each {|x| p x;}
	end 


	def print_rev_intersections
		p "---------";
		@reverse_intersections.each {|x| p x;}
	end 

end 


class Expressoin

	attr_accessor :tokens

	def initialize(string_expr)
		regexp_array = [];

		string_regexp = [/^"(\\.|[^"])*"/   ,1, true , 0.1];
		quote1_regexp = [/^'(\\.|[^'])*'/   ,2, true , 0.1];
		regexp_regexp = [/^\/(\\.|[^\/])*\//,3, true , 0.2];
		var_regexp    = [/^[[:word:]]+/     ,4, true , 0.1];
		spchar_regexp = [/^[^\w\s]/         ,5, true , 0  ];
		space_regexp  = [/^\s/              ,6, false, 0  ];


		regexp_array += [string_regexp]
		regexp_array += [quote1_regexp]
		regexp_array += [var_regexp   ]
		regexp_array += [spchar_regexp]
		regexp_array += [regexp_regexp]
		regexp_array += [space_regexp ]

		do_parse = true

		@tokens = [];
		
		while (do_parse)  do
			is_cmp = false
			regexp_array.each do |regexp|
				res = regexp[0].match(string_expr);
				if res != nil then
					is_cmp = true;
					@tokens += [Token.new(res[0], regexp[1], regexp[2], regexp[3])]
					size_of_token = res[0].size;
					string_expr = string_expr[size_of_token..-1];
					break;
				end
			end
			do_parse = is_cmp;
		end

	end
end




 t = Tree::TreeNode.new("root", []);
 
 #p check_prefix_tree(t, [1,2,3,4,5,6,7,8],1, 0)
 #p check_prefix_tree(t, [1,7,8], 1, 0)
 #p check_prefix_tree(t, [1,3,4,8], 1, 0)
 #p check_prefix_tree(t, [1,2,5,6,7,8], 1, 0)
 #p check_prefix_tree(t, [1,7,8], 1, 0)
 #p check_prefix_tree(t, [1,7,8], 2, 0)
 #p check_prefix_tree(t, [2,7,8], 2, 0)
 #p check_prefix_tree(t, [3,7,8], 2, 0)
 #p check_prefix_tree(t, [1,7,8], 2, 0)
 #p check_prefix_tree(t, [6,7,8], 2, 0)
 
# p check_prefix_tree(t, [1,2], 2, 1)
# p check_prefix_tree(t, [1,2], 2, 1)
# p check_prefix_tree(t, [1,2], 2, 1)
# 
#
# p check_prefix_tree(t, [1,2], 2, 2)
# p check_prefix_tree(t, [1,2], 2, 2)
# p check_prefix_tree(t, [1,2], 2, 2)
# 
#
# t.print_tree;
# 
# exit;
# 
# input_string1 = "regexp_array += [\"regexp regexp\"];";
# input_string2 = "test_varible -= [a + b];";

# input_string1 = "+ = ;"
# input_string2 = "; + ="

input_string1 = "= = - + +"
input_string2 = "= = - + +"


# regexp_array       += [\"regexp regexp\"];
# test_varible -= [a + b                  ];

# regexp_array += [\"regexp regexp\"];
# test_varible -= [a + b            ];


e1 = Expressoin.new(input_string1);
e2 = Expressoin.new(input_string2);

# e1.tokens.each {|x| p x;}
# p "----------";
# e2.tokens.each {|x| p x;}
# p "==========";

matcher = Matcher.new(e1.tokens, e2.tokens);

matcher.erase_insignificant_tokens;
matcher.print_tokens;

matcher.generate_pairs(0.01);
matcher.print_pairs;

matcher.get_intersection
matcher.print_intersections

p "------"

matcher.get_reverse_intersection_lists
matcher.print_rev_intersections()


p "------"
matcher.get_intersection_clusters

p "------"


matcher.do_generate_combinations

#matcher.generate_groups;
#matcher.print_groups;