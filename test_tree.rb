require './parser.rb'

#input_string = "@tokens += [Token.new(res[0], regexp[1], regexp[2], regexp[3])]";

input_string = "a = (b + ( n + [ m + l] ) )  ( ( } ] )";

e1 = Expression.new(input_string);

e1.erase_insignificant_tokens

tb = TreeBuilder.new(e1.tokens);



tb.parse_brakets().print_tree;