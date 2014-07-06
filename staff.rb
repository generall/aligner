require './heirarchy.rb'


def levenshtein(first, second)
	matrix = [(0..first.length).to_a]
	(1..second.length).each do |j|
		matrix << [j] + [0] * (first.length)
	end

	(1..second.length).each do |i|
		(1..first.length).each do |j|
			if first[j-1] == second[i-1]
				matrix[i][j] = matrix[i-1][j-1]
			else
				matrix[i][j] =
				[
					matrix[i-1][j  ],
					matrix[i  ][j-1],
					matrix[i-1][j-1],
				].min + 1
			end
		end
	end
	return matrix.last.last
end


class TypeData

	@@regexp_array = 
	[
		# [<reg_exp>, <tag>, <is_necessary>, <min_simularity>, <min_previous_space>, <min_follow_space> ]
		[/^'(\\.|[^'])*'/   , :quote   , true , 0.1, 0, 1],  # quote1_regexp
		[/^"(\\.|[^"])*"/   , :quote   , true , 0.1, 0, 1],  # string_regexp
		[/^\/(\\.|[^\/])*\//, :regexp  , true , 0.2, 0, 1],  # regexp_regexp
		[/^\@[[:word:]]+/   , :id      , true , 0.1, 0, 1],  # lvar_regexp
		[/^\@\@[[:word:]]+/ , :id      , true , 0.1, 0, 1],  # gvar_regexp
		[/^[[:word:]]+/     , :id      , true , 0.1, 0, 1],  # var_regexp
		[/^[\{\[\(\)\]\}]/  , :bracket , true , 0.1, 0, 1],  # bracket_regexp
		[/^[\=\+\-\*\&\^\~]/, :operator, true , 0.1, 0, 1],  # bracket_regexp
		[/^[^\w\s]/         , :spchar  , true , 0  , 0, 1],  # spchar_regexp
		[/^\s/              , :space   , false, 0  , 0, 1]   # space_regexp
	]

	def self.type_by_value(value)
		@@regexp_array.each do |regexp|
			res = regexp[0].match(value);
			if res != nil then
				return regexp[1];
			end
		end
	end

	def self.regexp_array()
		return @@regexp_array
	end

end

class Token
	attr_accessor :type, 
				:value, 
				:min_simularity, 
				:necessary, 
				:min_follow_space, 
				:min_previous_space, 
				:str_index, 
				:tkn_index;


	def initialize(value, type, necessary, min_simularity, min_previous_space, min_follow_space)
		@type               = type;
		@value              = value;
		@necessary          = necessary;
		@min_simularity     = min_simularity;
		@min_previous_space = min_previous_space;
		@min_follow_space   = min_follow_space;
		@str_index          = 0;
		@tkn_index          = 0;
	end

	def cmp(other_token)
		if other_token.class != Token then
			return 0
		end

		if(@type != other_token.type) then
			return 0;
		else
			return 0 if @necessary == false # for learning
			max_len = [@value.size, other_token.value.size].max
			res = 1.0 - levenshtein(@value, other_token.value).to_f / max_len + other_token.min_simularity;
			return res > 1.0 ? 1.0 : res;
		end
	end

	def inspect()
		return to_s()
	end

	def to_s()
		return "t"+@tkn_index.to_s + ":"+@value.to_s+""
		#return "[ t=" + @type.to_s + " v=" + @value.to_s + "]"
	end
end


class TokenTemplate
	attr_accessor :type, :value;

	def initialize(data = :any, except = [])

		if data.class == Symbol then
			@type   = data;
			@value  = :any;
		else
			# array expected
			@type  = TypeData.type_by_value(data[0])
			@value = data
		end
		@except = except;
	end

	def ==(other_token)
		if other_token.class == TokenTemplate then
			return equal? other_token;
		else
			if other_token.class == Token then
				return cmp(other_token);
			else
				return false 
			end
		end
	end

	def to_s()
		return "[ t=" + @type.to_s + " v=" + @value.to_s + "]"
	end

	def inspect()
		return to_s()
	end

	def cmp(other_token) # compare Token with TokenTemplate
		return !@except.include?(other_token.value) if @type == :any && other_token.type != :eof;
		if @value == :any then
			return @type.is_p_of?(other_token.type) && !@except.include?(other_token.value);
		else
			return @value.include?(other_token.value);
		end 
	end
end