require "./staff.rb";
require "./expression.rb"
require "./DP_matcher.rb"
require "./LR_parser"
require "./recreator.rb"
require "./space_configurator.rb"

class Array
	def self.intersection(a1, a2, &closure)
		index1 = index2 = 0;
		closure ||= lambda{ |x,y| x <=> y}
		result = [];

		while index1 < a1.size && index2 < a2.size do
			
			cmp_res = closure.call(a1[index1], a2[index2]);
			if cmp_res == 1 then
				# first is bigger
				index2 += 1;

			elsif cmp_res == 0 then
				# equal
				result += [[a1[index1],a2[index2]]];
				index1 += 1;
				index2 += 1;

			elsif cmp_res == -1 then
				# second is bigger
				index1 += 1;
			end

		end
		return result;
	end

	def self.intersection_index(a1, a2, &closure)
		index1 = index2 = 0;
		closure ||= lambda{ |x,y| x <=> y}
		result = [];

		while index1 < a1.size && index2 < a2.size do
			
			cmp_res = closure.call(a1[index1], a2[index2]);
			if cmp_res == 1 then
				# first is bigger
				index2 += 1;

			elsif cmp_res == 0 then
				# equal
				result += [[index1, index2]];
				index1 += 1;
				index2 += 1;

			elsif cmp_res == -1 then
				# second is bigger
				index1 += 1;
			end

		end
		return result;
	end
end


class Learner

	def initialize(type)
		@type = type
		TypeData.set_type type
		@Debug = true
		@data_max = [];
		@data_min = [];
	end

	def pairs_to_plane(pairs, meta1, meta2)
		res = [];
		pairs.each do |pair|
			if pair.size > 2 then
				res += pairs_to_plane(pair[2], meta1.value[pair[0]], meta2.value[pair[1]] )
			else
				res.push([meta1.value[pair[0]].tkn_index, meta2.value[pair[1]].tkn_index]);
			end
		end
		return res;
	end

	def generate_learning_data(strings)

		# get real pairs
		# get prospective pairs
		# compare
		exprs = strings.each.map{|x| Expression.new(x).erase_insignificant_tokens!}

		real_pairs = [];
		i = 0;
		tokens = [];
		tokens[0] = exprs[0].tokens;
		tokens[1] = exprs[1].tokens;

		pairs_by_strpos = Array.intersection_index(tokens[0], tokens[1]){|x,y| x.str_index <=> y.str_index}
		real_pairs = pairs_by_strpos.delete_if{|x| tokens[0][x[0]].cmp(tokens[1][x[1]]) < Float::EPSILON }

		if real_pairs[0][0] == 0 || real_pairs[0][1] == 0 then
			real_pairs.delete_at(0)
		end 
		p = LR_parser.new(@type)
		metas  = []
		strings.each { |str| metas.push(p.parse_meta(str)); }
		metas.each {|m| m.separate_first!}
		matcher = DPMatcher.new
		pairs_array = [];
		for i in 0..metas.size-2 do 
			pairs_array.push(matcher.generate_pairs(metas[i].value, metas[i+1].value));
		end

		expected_pairs = pairs_to_plane(pairs_array[0], metas[0], metas[1]);

		# p real_pairs
		# p expected_pairs

		# take pairs, that presents in expectation and not in reality;
		# Set substraction here
		uneven_pairs = expected_pairs - real_pairs;
		p uneven_pairs
		uneven_pairs.each do |pair|
			long_str_index  = strings[0].size >  strings[1].size ? 0 : 1;		
			short_str_index = strings[0].size <= strings[1].size ? 0 : 1;		
			
			info = {};
			info["prev" ]  = tokens[short_str_index][pair[short_str_index] - 1].value;
			info["next" ]  = tokens[short_str_index][pair[short_str_index]    ].value;

			info["delta"]  = (tokens[0][pair[0]].str_index - tokens[1][pair[1]].str_index).abs
			info["params"] = [];


			# info["params"].push(strings[short_str_index].size);
			# info["params"].push(strings[long_str_index ].size);
			# info["params"].push(tokens[long_str_index ][pair[long_str_index ]].str_index);
			# info["params"].push(tokens[short_str_index][pair[short_str_index]].str_index);
			# info["params"].push([tokens[0][pair[0]].str_index, tokens[1][pair[1]].str_index].max);
			info["params"].push(tokens[short_str_index][pair[short_str_index]].str_index);

			@data_max.push(info)

			if @Debug then
				p tokens[0][pair[0]].type.to_s + " - " + tokens[1][pair[1]].type.to_s; 
				p tokens[0][pair[0]].str_index
				p tokens[1][pair[1]].str_index
			end
		end
	end

	def extract_min_space_data(string)
		space_data = {};

		expr = Expression.new(string);
		ins = 0;
		expr.tokens.each do |x|  
			if x.necessary then
				space_data[x.tkn_index] = ins;
				ins = 0;
			else
				ins += 1;
			end
		end
		
		expr.erase_insignificant_tokens!;

		token_indexes = (1..expr.tokens.size-1).map{|x| x}

		token_indexes.each do |x|
			info = {};
			info["prev" ] = expr.tokens[x - 1].value;
			info["next" ] = expr.tokens[x    ].value;
			info["delta"] = space_data[x]

			@data_min.push(info);

			if (@Debug) then
				p info
			end
		end
	end

	def generalize()
		sc    = SpaceConf.new(@type)
		sc.min_by_type.clear();
		sc.max_by_type.clear();

		sum   = {};
		count = {};

		sum.default   = 0;
		count.default = 0;
		
		# generalization of upper bound
		@data_min.each do |info|
			t1 = TypeData.type_by_value(info["prev"] )
			while t1 != nil do  
				t2 = TypeData.type_by_value(info["next"] )
				while t2 != nil do
					ident = [t1, t2]
					sum  [ident] += info["delta"];
					count[ident] += 1;
					t2 = TypeHierarchy.get_parent(t2, @type)
				end
				t1 = TypeHierarchy.get_parent(t1, @type)
			end
		end

		p sum
		p count

		sum.keys.each do |ident|
			sc.min_by_type[ident] = (sum[ident].to_f / count[ident]).round
		end

		sc.max_by_type.default = [];
		@data_max.each do |info|
			ident = [TypeData.type_by_value(info["prev"], @type), TypeData.type_by_value(info["next"], @type)]
			sc.max_by_type[ident] += [[info["delta"], info["params"]]];
		end

		puts sc.to_s;

		sc.save();

	end
end
