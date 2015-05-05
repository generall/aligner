
require "./staff.rb"
require 'colorize'  if $DEBUG_project > 0


class MetaExpression
	attr_accessor :value, :parent, :first;

	def initialize(parent = nil)
		@parent = parent;
		@value  = []    ;
		@first  = nil   ;
	end


	def cmp(token_or_meta)
		if token_or_meta.class == Token then
			return 0;
		else
			return 0.1;
		end
	end

	def print_tree(n = 0)
		@value.each do |token|
			if token.class == Token then
				print " "*n*4;
				p token;
			else
				token.print_tree(n+1)
			end
		end
	end

	def separate_first!
		v = @value[0];
		prev = nil;
		while v.class != Token do
			prev = v;
			v = v.value[0];
		end
		@first = v;
		if prev != nil then
			prev.value = prev.value[1..-1]
			while prev.value == [] && prev != self do
				prev = prev.parent
				prev.value = prev.value[1..-1]
			end
		else
			@value = @value[1..-1]
		end		
	end

	def get_last_token()
		if @value.last.class == MetaExpression then
			return @value.last.get_last_token
		else
			return @value.last
		end
	end

	def get_first_token()
		if @value.first.class == MetaExpression then
			return @value.first.get_first_token
		else
			return @value.first
		end
	end

	def 

	def min_previous_space
		get_first_token.min_previous_space
	end

	def min_follow_space
		get_last_token.min_follow_space
	end

	def inspect
		return to_s
	end

	def to_s
		return @value.to_s
	end

end


class Expression

	attr_accessor :tokens

	def initialize(string_expr = nil)
		parse(string_expr) if string_expr != nil;

	end


	def parse(string_expr)

		do_parse = true

		@tokens = [];
		
		str_index = 0; 
		tkn_index = 0;
		while (do_parse)  do
			is_cmp = false
			TypeData.regexp_array.each do |regexp|
				res = regexp[0].match(string_expr);
				if res != nil then
					is_cmp = true;
					@tokens += [Token.new(res[0], regexp[1], regexp[2], regexp[3], regexp[4], regexp[5])]
					size_of_token          =  res[0].size;
					@tokens.last.str_index =  str_index;
					@tokens.last.tkn_index =  tkn_index;
					str_index              += size_of_token;
					tkn_index              += 1 if regexp[2]; # significant tokens only
					string_expr            =  string_expr[size_of_token..-1];
					break;
				end
			end
			do_parse = is_cmp;
		end

	end

	# Delete tokens, wich marked as insignificant + reorded arrays by size
	def erase_insignificant_tokens!
		i = 0;
		while i < @tokens.size do
			if @tokens[i].necessary == false then
				@tokens.delete_at(i);
				i -=1;
			end
			i+=1;
		end
		return self;
	end

	def print_tokens()
		@tokens.each_with_index{|x,i| p [i,x];}
	end
end


