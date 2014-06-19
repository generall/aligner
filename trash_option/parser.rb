require 'tree'
require "./staff.rb";
require "./expression.rb"



class TreeBuilder
	def initialize(token_array1)
		@tokens = token_array1;

		@brackets = {
					 '(' => ')',
					 '[' => ']',
					 '{' => '}'
					}
		#@rev_brackets = Hash[@brackets.map{|x,y| [y,x]];
	end

	def parse_brakets()
		stack = [];
		root_expr = MetaExpression.new
		curr_expr = root_expr;
		@tokens.each do |token|
			if token.type == :spchar && @brackets[token.value] != nil then
				stack.push(@brackets[token.value]);
				curr_expr.value += [token];
				t = MetaExpression.new(curr_expr)
				curr_expr.value += [t];
				curr_expr = t;
			else
				if token.type == :spchar && token.value == stack.last then
					curr_expr = curr_expr.parent;
					curr_expr.value += [token]
					stack.pop;
				else
					curr_expr.value += [token];
				end
			end
		end
		while stack.size != 0 do
			curr_expr.parent.value.pop; # delete unused child
			curr_expr.parent.value += curr_expr.value;
			curr_expr = curr_expr.parent;
			stack.pop;
		end

		return root_expr;
	end

end
