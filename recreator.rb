require "./staff.rb";
require "./expression.rb"
require "./space_configurator.rb"

class Range
  def intersection(other)
    return nil if (self.max < other.begin or other.max < self.begin) 
    [self.begin, other.begin].max..[self.max, other.max].min
  end
  alias_method :&, :intersection
end


class Array
	def bubble_sort!(&closure)
		closure ||= lambda{ |x,y| x <=> y}

		for i in 0..size-1 do
			for j in 0..size-2 do
				cmp = closure.call(self[j], self[j + 1]);
				if cmp == 1 then
					self[j + 1], self[j] = self[j], self[j + 1]
				end
			end
		end

	end
end

class Recreator

	def initialize(type)
		@type = type
		@Debug = true & false;
		@sc = SpaceConf.new(type)
	end

	def set_debug(d)
		@Debug = d;
	end


	def get_string_from_meta(meta)
		res_str  = meta.first == nil ? "" : meta.first.value;
		prev_min = meta.first;
		meta.value.each do |token|
			if token.class == MetaExpression then
				min_spaces = @sc.get_min(prev_min, token.get_first_token) 
				if @Debug then
					p "from ", prev_min.type
					p "to", token.get_first_token.type
					p min_spaces
				end
				res_str += " " * min_spaces;
				res_str += get_string_from_meta(token);

				prev_min = token.get_last_token;
			else
				min_spaces = @sc.get_min(prev_min, token)
				if @Debug then
					p "from ", prev_min.type
					p "to", token.type
					p min_spaces
				end
				res_str += " " * min_spaces;
				res_str += token.value;

				prev_min = token;
			end
		end
		return res_str;
	end

	# input : [Meta, ...], [chain, ...], [prev, ...]
	# output: [string, ...]
	def multiline_reconstruction(meta_array, chains)

		n = meta_array.size;

		indexes = [0]*n;

		@prev_tokens ||= [];

		res_strings = meta_array.map{|meta| meta.first == nil ? "" : meta.first.value;}
		meta_array.each_with_index{|meta, i| @prev_tokens[i] ||= meta.first;}

		
		reconstruct_line_to = lambda do |line_index, end_index|
			while indexes[line_index] != end_index do
				t_token = meta_array[line_index].value[indexes[line_index]]
				begin
				if t_token.class == Token then
					min_spaces = @sc.get_min(@prev_tokens[line_index], t_token)
					if @Debug then
						p "from ", @prev_tokens[line_index].type
						p "to", t_token.type
						p min_spaces
					end
					res_strings[line_index] += " "*min_spaces;
					res_strings[line_index] += t_token.value;
					@prev_tokens[line_index]  = t_token;
				else
					min_spaces = @sc.get_min(@prev_tokens[line_index], t_token.get_first_token)
					if @Debug then
						p "from ", @prev_tokens[line_index].type
						p "to", t_token.get_first_token.type
						p min_spaces
					end
					res_strings[line_index] += " "*min_spaces;
					res_strings[line_index] += get_string_from_meta(t_token);
					@prev_tokens[line_index]  = t_token.get_last_token;
				end
				rescue
					p "Exceprion: "
					p "line_index: " + line_index.to_s
					p "token_index: " + indexes[line_index].to_s
					p "end_index: " + end_index.to_s
					p "metas: " + meta_array[line_index].value.to_s

					exit();
				end
				indexes[line_index] += 1;
			end
		end
		# chain processing

		chains.each do |chain|

			begin_line = chain[0];
			end_line   = begin_line + chain[1].size

			line_index = chain[0];

			#byebug

			chain[1].each do |pair|
				reconstruct_line_to.call(line_index, pair[0])
				line_index += 1;
				reconstruct_line_to.call(line_index, pair[1])
			end
			
			#debugger
			# TODO some fix here 
			if chain.size <= 2
				for i in begin_line..end_line do
					min_spaces = @sc.get_min(@prev_tokens[i], meta_array[i].value[indexes[i]])
					res_strings[i] += " "*min_spaces
				end
			end
			
			# delta calculation here
			max_size = 0;
			for i in begin_line..end_line do
				max_size = [max_size, res_strings[i].size].max;
			end
			delta = {}
			for i in begin_line..end_line do
				delta[i] = max_size - res_strings[i].size
			end


			# limitations here
			for i in begin_line..end_line do
				accept = true;

				if delta[i] > 0 then
					t1 = @prev_tokens[i]
					t2 = meta_array[i].value[indexes[i]];
					if t2.class == MetaExpression
						t2 = t2.get_first_token
					end
					params = [];
					params.push(t2.str_index);
					limit =  @sc.get_max(t1, t2, params);
					accept = delta[i] < limit;
					if @Debug & false then
						p "prev: " + t1.type .to_s;
						p "next: " + t2.type .to_s;
						p "delta:" + delta[i].to_s;
						p "max:  " + limit   .to_s;
					end
				end
				res_strings[i] += " "*delta[i] if accept;
			end

			if chain.size > 2
				# recursivity

				metas = n.times.map{MetaExpression.new};
				for i in begin_line..end_line do
					metas[i] = meta_array[i].value[indexes[i]]
				end
				strings = multiline_reconstruction(metas, chain[2])

				for i in begin_line..end_line do
					res_strings[i] += strings[i];
					indexes[i] += 1;
				end

			else
				for i in begin_line..end_line do
					res_strings[i] += meta_array[i].value[indexes[i]].value
					@prev_tokens[i]  = meta_array[i].value[indexes[i]]
					indexes[i] += 1;
				end
			end
		end

		for i in 0..n-1 do
			reconstruct_line_to.call(i, meta_array[i].value.size)
		end
		return res_strings
	end


	# input [ [ [index, index], [i, i], ... ], ...]
	# output [ [line_id, [[token-id, token-id], [t-id, t-id], ...]], .... ]

	def generate_chains(pairs_array)
		n = pairs_array.size();
		used_indexes = n.times.map{{}};
		curr_indexes = [  0  ] * n;
		chains = [];

		for i in 0..n-1 do
			while curr_indexes[i] < pairs_array[i].size do 
				if used_indexes[i][curr_indexes[i]] != nil
					curr_indexes[i] += 1;
					next;
				end
				used_indexes[i][curr_indexes[i]] = 1;
				# start chain creation
				child_pairs = n.times.map{[]};

				rec = pairs_array[i][curr_indexes[i]][2] != nil;

				child_pairs[i] = (pairs_array[i][curr_indexes[i]][2]) if pairs_array[i][curr_indexes[i]][2] != nil
				chain = 
				[i,
					[
						[
							pairs_array[i][curr_indexes[i]][0],
							pairs_array[i][curr_indexes[i]][1]
						]
					]
				];
				k = i + 1;
				tid = pairs_array[i][curr_indexes[i]][1];
				while k != n do
					nexus = pairs_array[k].drop(curr_indexes[k]).index{|x| x[0] == tid}
					if (nexus == nil) then
						break;
					else
						nexus += curr_indexes[k];
						break if used_indexes[k][nexus] != nil
						used_indexes[k][nexus] = 1;
						
						child_pairs[k] = (pairs_array[k][nexus][2]) if pairs_array[k][nexus][2] != nil

						chain[1].push([pairs_array[k][nexus][0],pairs_array[k][nexus][1]]);
						tid = pairs_array[k][nexus][1];
						k += 1;
					end
				end
				chain.push(generate_chains(child_pairs)) if rec
				chains.push(chain);

				curr_indexes[i] += 1;
			end
		end

		# sort
		chains.bubble_sort! do |x,y|
			# TODO add intersection here! Add convertation to line!
			x_range = x[0]..(x[0] + x[1].size)
			y_range = y[0]..(y[0] + y[1].size)


			str_inter = x_range & y_range;

			x_min = 0;
			y_min = 0;

			x_by_lines = x[1].map{|i| i[0]} + [x[1].last[1]]
			y_by_lines = y[1].map{|i| i[0]} + [y[1].last[1]]

			if str_inter != nil
				x_range = str_inter;
				y_range = str_inter;
			end
			
			x_range.each{ |i| x_min = [x_min, x_by_lines[i - x[0]]].max }
			y_range.each{ |i| y_min = [y_min, y_by_lines[i - y[0]]].max }
			x_min <=> y_min;
		end

		return chains;
	end
end