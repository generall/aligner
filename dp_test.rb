require "./staff.rb";
require "./expression.rb"

input_string1 = "f(a+b,c)";
input_string2 = "f(m, g)";

e1 = Expression.new(input_string1);
e2 = Expression.new(input_string2);


e1.erase_insignificant_tokens
e2.erase_insignificant_tokens


e1.print_tokens()
e2.print_tokens()

p matcher.get_pairs(e1.tokens, e2.tokens)