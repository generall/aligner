require "./align.rb"


input_strings = [];

input_strings.push("@type = type;");
#input_strings.push("@value = value;");
input_strings.push("@except = except;");

indents = [];
input_strings.each {|str| indents.push(get_indent(str)); }

#input_strings.push("f(a + b)(b + c)");
#input_strings.push("f(a)(b - c)");
#input_strings.push("g(b - c)()");
#input_strings.push("d(b - c)(c)");
#input_strings.push("1 0 + ^ ^ $ : ");
#input_strings.push("1 0 ! + $ % ; ");
#input_strings.push("1 0 @ + $ % ; ");
#input_strings.push("1 0 - @ ;     ");
#input_strings.push("1 0 - @ ;     ");

lines = test_aligment(input_strings)

lines.each{|x| p x}

=begin
lines = Recreator.new.reconstruct(m1, m2, pairs);


p lines[0]
p lines[1]
=end