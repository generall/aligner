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

	# input : [Meta, ...], [chain, ...], [prev, ...]
	# output: [string, ...]
	def multiline_reconstruction(meta_array, chains, prev_array = nil)
		n = meta_array.size;

		prev_array = [nil]*n if prev_array == nil;
		indexes = [0]*n;

		res_strings = meta_array.map{|meta| meta.first == nil ? "" : meta.first.value;}
		prev_tokens = meta_array.map{|meta| meta.first;}
		
		for i in 0..n-1 do
			prev_tokens[i] = prev_array[i] if prev_array[i] != nil;
		end

		reconstruct_line_to = lambda do |line_index, end_index|
			while indexes[line_index] != end_index do
				t_token = meta_array[line_index].value[indexes[line_index]]
				if t_token.class == Token then
					min_spaces = [prev_tokens[line_index].min_follow_spase, t_token.min_previous_spase].max
					res_strings[line_index] += " "*min_spaces;
					res_strings[line_index] += t_token.value;
					prev_tokens[line_index]  = t_token;
				else
					min_spaces = [prev_tokens[line_index].min_follow_spase, t_token.get_first_token.min_previous_spase].max
					res_strings[line_index] += " "*min_spaces;
					res_strings[line_index] += get_string_from_meta(t_token);
					prev_tokens[line_index]  = t_token.get_last_token;
				end
				indexes[line_index] += 1;
			end
		end
		# chain processing
		chains.each do |chain|
			begin_line = chain[0];
			end_line   = begin_line + chain[1].size

			line_index = chain[0];


			chain[1].each do |pair|
				reconstruct_line_to.call(line_index, pair[0])
				line_index += 1;
				reconstruct_line_to.call(line_index, pair[1])
			end
			

			if chain.size <= 2
				for i in begin_line..end_line do
					min_space = [prev_tokens[i].min_follow_spase, meta_array[i].value[indexes[i]].min_previous_spase].max
					res_strings[i] += " "*min_space
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
				res_strings[i] += " "*delta[i];
			end

			if chain.size > 2
				# recursivity

				metas = n.times.map{MetaExpression.new};
				for i in begin_line..end_line do
					metas[i] = meta_array[i].value[indexes[i]]
				end
				p metas
				strings = multiline_reconstruction(metas, chain[2], prev_tokens)

				for i in begin_line..end_line do
					res_strings[i] += strings[i];
					indexes[i] += 1;
				end

			else
				for i in begin_line..end_line do
					res_strings[i] += meta_array[i].value[indexes[i]].value
					prev_tokens[i]  = meta_array[i].value[indexes[i]]
					indexes[i] += 1;
				end
			end
		end

		for i in 0..n-1 do
			p meta_array[i]
			reconstruct_line_to.call(i, meta_array[i].value.size)
		end
		return res_strings
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
		chains.sort! do |x,y|
			x_min = 0;
			y_min = 0;
			x[1].each{ |pair| x_min = [x_min, pair[0], pair[1]].max }
			y[1].each{ |pair| y_min = [y_min, pair[0], pair[1]].max }
			x_min <=> y_min;
		end

		return chains;
	end
end