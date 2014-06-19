require "./matcher.rb"


class Formater
	def initialize(string_list, min_simularity)
		@lines = string_list;
		@min_simularity = min_simularity;
	end

	def get_groups()
		@exprs = [];
		@lines.each do |line|
			@exprs += [Expression.new(line)];
		end

		@ranges = [];
		@combinations = [];
		prev = 0;
		for i in 0..@exprs.size-2 do
			matcher = Matcher.new(@exprs[i].tokens, @exprs[i+1].tokens);
			matcher.erase_insignificant_tokens;
			matcher.generate_pairs(0.01);
			matcher.get_intersection;
			matcher.get_intersection_clusters
			c = matcher.do_generate_combinations
			@combinations += [matcher.get_pairs_from_combination(c)];
			sim = matcher.simularity;
				
			p @combinations.last;
			p sim;

			if sim < @min_simularity then
				@ranges += [Rande.new(prev, i-1)];
				prev = i;
			end
		end

		#@combinations.each {|x| p x; }
		p @randes;
	end

end

lines = [];
File.new("test.txt").each_line {|line| lines += [line] }

f = Formater.new(lines, 0.001);
f.get_groups;
