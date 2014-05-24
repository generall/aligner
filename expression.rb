
class MetaExpression
	attr_accessor :value, :parent

	def initialize(parent = nil)
		@parent = parent;
		@value  = [];
	end

	def cmp(token_or_metaexpression)
		if token_or_metaexpression.class == Token then
			return 0;
		else
			#
			# Matcher here.
			return 1;
		end
	end

	def print_tree(n = 0)
		@value.each do |token|
			if token.class == Token then
				print " "*n*4;
				p token.value;
			else
				token.print_tree(n+1)
			end
		end
	end
end

class Expression

	attr_accessor :tokens

	def initialize(string_expr)
		regexp_array = [];

		quote1_regexp = [/^'(\\.|[^'])*'/   , :quote  , true , 0.1];
		string_regexp = [/^"(\\.|[^"])*"/   , :quote  , true , 0.1];
		regexp_regexp = [/^\/(\\.|[^\/])*\//, :regexp , true , 0.2];
		lvar_regexp   = [/^\@[[:word:]]+/   , :id     , true , 0.1];
		gvar_regexp   = [/^\@\@[[:word:]]+/ , :id     , true , 0.1];
		var_regexp    = [/^[[:word:]]+/     , :id     , true , 0.1];
		spchar_regexp = [/^[^\w\s]/         , :spchar , true , 0  ];
		space_regexp  = [/^\s/              , :space  , false, 0  ];


		regexp_array += [string_regexp]
		regexp_array += [quote1_regexp]
		regexp_array += [lvar_regexp  ]
		regexp_array += [gvar_regexp  ]
		regexp_array += [var_regexp   ]
		regexp_array += [spchar_regexp]
		regexp_array += [regexp_regexp]
		regexp_array += [space_regexp ]

		do_parse = true

		@tokens = [];
		
		while (do_parse)  do
			is_cmp = false
			regexp_array.each do |regexp|
				res = regexp[0].match(string_expr);
				if res != nil then
					is_cmp = true;
					@tokens += [Token.new(res[0], regexp[1], regexp[2], regexp[3])]
					size_of_token = res[0].size;
					string_expr = string_expr[size_of_token..-1];
					break;
				end
			end
			do_parse = is_cmp;
		end
	end

	# Delete tokens, wich marked as insignificant + reorded arrays by size
	def erase_insignificant_tokens
		i = 0;
		while i < @tokens.size do
			if @tokens[i].necessary == false then
				@tokens.delete_at(i);
				i -=1;
			end
			i+=1;
		end
	end

	def print_tokens()
		@tokens.each_with_index{|x,i| p [i,x];}
	end
end


