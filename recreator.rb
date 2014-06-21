require "./staff.rb";
require "./expression.rb"


class Recreator

	def get_string_from_meta(meta)
		res_str  = meta.first == nil ? "" : meta.first.value;
		prev_min = meta.first == nil ? 0  : meta.first.min_follow_spase;
		meta.value.each do |token|
			if token.class == MetaExpression then
				min_spaces = [token.get_first_token.min_previous_spase, prev_min].max;
				res_str += " " * min_spaces;
				res_str += get_string_from_meta(token);

				prev_min = token.get_last_token.min_follow_spase;
			else
				min_spaces = [token.min_previous_spase, prev_min].max;
				res_str += " " * min_spaces;
				res_str += token.value;

				prev_min = token.min_follow_spase;
			end
		end
		return res_str;
	end

	# input: MetaExpression, MetaExpression, 
	# return: [string, string]
	def reconstruct(meta1, meta2, pairs, prev1 = nil, prev2 = nil)
		m1_iterator    = 0;
		m2_iterator    = 0;
		result_string1 = meta1.first == nil ? "" : meta1.first.value;
		result_string2 = meta2.first == nil ? "" : meta2.first.value;

		prev_token1 = meta1.first;
		prev_token2 = meta2.first;

		prev_token1 = prev1 == nil ? prev_token1 : prev1;
		prev_token2 = prev2 == nil ? prev_token2 : prev2;

		pairs.each do |pair|
			while m1_iterator != pair[0] do
				if meta1.value[m1_iterator].class == Token then
					min_spaces = [prev_token1.min_follow_spase, meta1.value[m1_iterator].min_previous_spase].max
					result_string1 += " "*min_spaces;
					result_string1 += meta1.value[m1_iterator].value;
					prev_token1     = meta1.value[m1_iterator];
				else
					min_spaces = [prev_token1.min_follow_spase, meta1.value[m1_iterator].get_first_token.min_previous_spase].max
					result_string1 += " "*min_spaces;
					result_string1 += get_string_from_meta(meta1.value[m1_iterator]);
					prev_token1     = meta1.value[m1_iterator].get_last_token;
				end
				m1_iterator += 1;
			end
			while m2_iterator != pair[1] do
				if meta2.value[m2_iterator].class == Token then
					min_spaces = [prev_token2.min_follow_spase, meta2.value[m2_iterator].min_previous_spase].max
					result_string2 += " "*min_spaces;
					result_string2 += meta2.value[m2_iterator].value;
					prev_token2     = meta2.value[m2_iterator]
				else
					min_spaces = [prev_token2.min_follow_spase, meta2.value[m2_iterator].get_first_token.min_previous_spase].max
					result_string2 += " "*min_spaces;
					result_string2 += get_string_from_meta(meta2.value[m2_iterator]);
					prev_token2     = meta2.value[m2_iterator].get_last_token;
				end
				m2_iterator += 1;
			end

			# Aligment here
			if pair.size > 2 then
				strings = reconstruct(meta1.value[m1_iterator], meta2.value[m2_iterator], pair[2], prev_token1, prev_token2)

				prev_token1 = meta1.value[m1_iterator].get_last_token;
				prev_token2 = meta2.value[m2_iterator].get_last_token;

				delta = result_string1.size - result_string2.size
				result_string1 += " "*delta.abs if result_string2.size > result_string1.size
				result_string2 += " "*delta.abs if result_string2.size < result_string1.size

				result_string1 += strings[0];
				result_string2 += strings[1];
			else
				min_spaces1 = [prev_token1.min_follow_spase, meta1.value[m1_iterator].min_previous_spase].max
				min_spaces2 = [prev_token2.min_follow_spase, meta2.value[m2_iterator].min_previous_spase].max

				result_string1 += " " * min_spaces1;
				result_string2 += " " * min_spaces2;

				delta = result_string1.size - result_string2.size
				result_string1 += " " * delta.abs if result_string2.size > result_string1.size
				result_string2 += " " * delta.abs if result_string2.size < result_string1.size
				
				result_string1 += meta1.value[m1_iterator].value;
				result_string2 += meta2.value[m2_iterator].value;
				prev_token1     = meta1.value[m1_iterator]
				prev_token2     = meta2.value[m2_iterator]
			end
			m1_iterator    += 1;
			m2_iterator    += 1;
		end

		while m1_iterator != meta1.value.size do
			if meta1.value[m1_iterator].class == Token then
				min_spaces = [prev_token1.min_follow_spase, meta1.value[m1_iterator].min_previous_spase].max
				result_string1 += " "*min_spaces;
				result_string1 += meta1.value[m1_iterator].value;
				prev_token1     = meta1.value[m1_iterator];
			else
				min_spaces = [prev_token1.min_follow_spase, meta1.value[m1_iterator].get_first_token.min_previous_spase].max
				result_string1 += " "*min_spaces;
				result_string1 += get_string_from_meta(meta1.value[m1_iterator]);
				prev_token1     = meta1.value[m1_iterator].get_last_token;
			end
			m1_iterator += 1;
		end
		while m2_iterator != meta2.value.size do
			if meta2.value[m2_iterator].class == Token then
				min_spaces = [prev_token2.min_follow_spase, meta2.value[m2_iterator].min_previous_spase].max
				result_string2 += " "*min_spaces;
				result_string2 += meta2.value[m2_iterator].value;
				prev_token2     = meta2.value[m2_iterator]
			else
				min_spaces = [prev_token2.min_follow_spase, meta2.value[m2_iterator].get_first_token.min_previous_spase].max
				result_string2 += " "*min_spaces;
				result_string2 += get_string_from_meta(meta2.value[m2_iterator]);
				prev_token2     = meta2.value[m2_iterator].get_last_token;
			end
			m2_iterator += 1;
		end
		return [result_string1, result_string2]
	end

	# input : [Meta, ...], [pairs, ...], [prev, ...]
	# output: [string, ...]
	def multiline_reconstruction(meta_array, pairs_array, prev_array = nil)
		n = meta_array.size;

		prev_array = [nil]*n if prev_array == nil;
		indexes = [0]*n;

		res_strings = meta_array.map{|meta| meta.first == nil ? "" : meta.first.value;}
		prev_tokens = meta_array.map{|meta| meta.first;}
		
		for i in 0..n do
			prev_tokens[i] = prev_array[i] if prev_array[i] != nil;
		end
	end


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
			if pairs_array[i][curr_indexes[i]].size <= 2 then
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
				p "tid:" + tid.to_s
				while k != n do
					nexus = pairs_array[k].drop(curr_indexes[k]).index{|x| x[0] == tid}
					if (nexus == nil) then
						break;
					else
						nexus += curr_indexes[k];
						break if used_indexes[k][nexus] != nil
						used_indexes[k][nexus] = 1;
						chain[1].push([pairs_array[k][nexus][0],pairs_array[k][nexus][1]]);
						tid = pairs_array[k][nexus][1];
						k += 1;
					end
				end
					chains.push(chain);
				else
					# TODO recursivity
				end
				curr_indexes[i] += 1;
			end
		end
		return chains;
	end
end