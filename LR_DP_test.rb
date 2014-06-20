require "./staff.rb";
require "./expression.rb"
require "./DP_matcher.rb"
require "./LR_parser"
require "./recreator.rb"


def get_indent(str)
	indent = str.match(/^\s/)
	return indent[0] if(indent != nil)
	return "";
end

input_string1 = "f(a)(a+b)";
input_string2 = "g()(c-d)";

indent1 = get_indent(input_string1);
indent2 = get_indent(input_string2);

if indent1 != indent2 then
	p "different indention: abort"
	exit
end

p = LR_parser.new

m1 = p.parse_meta(input_string1) 
m2 = p.parse_meta(input_string2)

m1.separate_first!; # separate first token to prevent indention
m2.separate_first!;

m1.print_tree
puts
m2.print_tree

# p m1.value
# puts 
# p m2.value

matcher = DPMatcher.new

pairs = matcher.generate_pairs(m1.value, m2.value)

p m1
p m2

lines = Recreator.new.reconstruct(m1, m2, pairs);


p lines[0]
p lines[1]