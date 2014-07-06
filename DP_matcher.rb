require "./expression.rb"


class DPMatcher
	def initialize()
		@cache = {};

	end

	def match(x,y,i,j)
		if(@cache[[i,j]] != nil) then
			return @cache[[i,j]][0];
		end

		if x.size == i then
			@cache[[i,j]] = [0, 3];
			return 0;
		end
		if y.size == j then
			@cache[[i,j]] = [0, 3];
			return 0;
		end

		value = [];
		value[0] = x[i].cmp(y[j]) + match(x,y,i+1,j+1)
		value[1] = match(x, y, i  ,j+1)
		value[2] = match(x, y, i+1,j  )

		max_value = 0;
		max_index = 0;
		index = 0;
		value.each{
			|x|
			if x > max_value then
				max_value = x;
				max_index = index; 
			end
			index += 1;
		}
		@cache[[i,j]] = [max_value, max_index];
		return max_value;
	end

	def get_pairs(x,y, start = 0)
		@cache = {};
		match(x, y, start, start);
		pairs = [];
		i = j = start;
		curr  = @cache[[i,j]][1]
		while curr != 3
			case curr
			when 0 then
				pairs += [[i,j]] if x[i].cmp(y[j]) > Float::EPSILON
				i+=1;
				j+=1;
			when 1 then
				j+=1;	
			when 2 then
				i+=1;	
			end
			curr = @cache[[i,j]][1]
		end
		return [@cache[[start, start]][0], pairs];
	end

	def generate_pairs(values1, values2)
		pairs = get_pairs(values1, values2)[1]
		for i in 0..pairs.size-1 do
			if values1[pairs[i][0]].class == MetaExpression && values2[pairs[i][1]].class == MetaExpression then
				pairs[i] += [generate_pairs(values1[pairs[i][0]].value, values2[pairs[i][1]].value)];
			end
		end
		return pairs
	end

	# Filter pairs in 3-lines
	# input: recursive pair array * 2
	# output: [new_pair_array1, new_pair_array2]
	def reconsider_pairs(pairs1, pairs2)
		out_pairs1 = [];
		out_pairs2 = [];
		p1_index = 0;
		p2_index = 0;

		while p1_index != pairs1.size && p2_index != pairs2.size do
			if (pairs1[p1_index][1] == pairs2[p2_index][0]) then
				out_pairs1.append([pairs1[p1_index][0],pairs1[p1_index][1]])
				out_pairs2.append([pairs2[p2_index][0],pairs2[p2_index][1]])

				if(pairs1[p1_index].size > 2 && pairs1[p2_index].size > 2) then
					internal_res = reconsider_pairs(pairs1[p1_index][2], pairs2[p2_index][2]);
					out_pairs1.last.push(internal_res[0])
					out_pairs2.last.push(internal_res[1])
				end
				p1_index += 1;
				p2_index += 1;
				next;
			end
			if(pairs1[p1_index][1] > pairs2[p2_index][0]) then
				p2_index += 1;
				next;
			end
			if(pairs1[p1_index][1] < pairs2[p2_index][0]) then
				p1_index += 1;
				next;
			end
		end
		return [out_pairs1, out_pairs2];
	end

	# input: [meta1, meta2], [[i1,i2], [i1,i2], ....]
	# output: float

	def get_simularity(metas, pairs, n = [0])
		sum = 0.0;
		pairs.each do |pair|
			if pair.size > 2 then
				n[0] -= 1;
				# magic numbers here
				sum += get_simularity([metas[0].value[pair[0]], metas[1].value[pair[1]]], pair[2], n);
			else
				sum += metas[0].value[pair[0]].cmp(metas[1].value[pair[1]]);
			end
		end
		n[0] += [metas[0].value.size(), metas[1].value.size()].max;
		return sum;
	end

	def get_percent_simularity(metas, pairs)
		n = [0];
		s = get_simularity(metas, pairs, n);
		return s / n[0].to_f;
	end
end

