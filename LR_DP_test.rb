require "./staff.rb";
require "./expression.rb"
require "./DP_matcher.rb"
require "./LR_parser"


def generate_pairs(values1, values2)
	matcher = DPMatcher.new
	pairs = matcher.get_pairs(values1, values2)[1]

	for i in 0..pairs.size-1 do
		if values1[pairs[i][0]].class == MetaExpression && values2[pairs[i][1]].class == MetaExpression then
			pairs[i] += [generate_pairs(values1[pairs[i][0]].value, values2[pairs[i][1]].value)];
		end
	end

	return pairs
end


input_string1 = "f()(a+b)";
input_string2 = "a";


p = LR_parser.new

m1 = p.parse_meta(input_string1) 
m2 = p.parse_meta(input_string2)

m1.separate_first; # separate first token to prevent indention
m2.separate_first;

m1.print_tree
m2.print_tree

# p m1.value
# puts 
# p m2.value

p generate_pairs(m1.value, m2.value)

