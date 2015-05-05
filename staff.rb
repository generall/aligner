require './heirarchy.rb'
require 'colorize'  if $DEBUG_project > 0


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
					matrix[i - 1][j    ],
					matrix[i    ][j - 1],
					matrix[i - 1][j - 1],
				].min + 1
			end
		end
	end
	return matrix.last.last
end


class TypeData

	@@type = :none

	def self.set_type(t)
		@@type = t;
	end

	@@regexp_array = {}

	@@regexp_array[:default1] = 
	[
		# [<reg_exp>, <tag>, <is_necessary>, <min_simularity>, <min_previous_space>, <min_follow_space> ]
		[/^'(\\.|[^'])*'/                 , :quote , true , 0.1, 0, 1], # quote1_regexp
		[/^"(\\.|[^"])*"/                 , :quote , true , 0.1, 0, 1], # string_regexp
		[/^[-+]?\d*\.?\d+([eE][-+]?\d+)?/ , :float , true , 0.1, 0, 1], # float
		[/^([-+]?\d*\.?\d+)/              , :float , true , 0.1, 0, 1], # float
		[/^\d+/                , :int         , true  , 0.1, 0, 1], # integer
		[/^[\.\,\;]/           , :punctuation , true  , 0.1, 0, 1], # punctuation
		[/^[\{\[\(\)\]\}]/     , :bracket     , true  , 0.1, 0, 1], # bracket_regexp
		[/^[\=\+\-\*\&\^\~\|]/ , :operator    , true  , 0.1, 0, 1], # bracket_regexp
		[/^[^\w\s][[:word:]]+/ , :id          , true  , 0.1, 0, 1], # id
		[/^[[:word:]]+/        , :id          , true  , 0.1, 0, 1], # var_regexp
		[/^[^\w\s]/            , :spchar      , true  , 0,   0, 1], # spchar_regexp
		[/^\s/                 , :space       , false , 0,   0, 1]  # space_regexp
	]


	#separated by space
	# + string constants
	# + brakets

	@@regexp_array[:default] = 
	[
		# [<reg_exp>, <tag>, <is_necessary>, <min_simularity>, <min_previous_space>, <min_follow_space> ]
		[/^'(\\.|[^'])*'/          , :quote   , true  , 0.1, 0, 1], # quote1_regexp
		[/^"(\\.|[^"])*"/          , :quote   , true  , 0.1, 0, 1], # string_regexp
		[/^[\{\[\(\)\]\}]/         , :bracket , true  , 0.1, 0, 1], # bracket_regexp
		[/^[^\s\{\[\(\)\]\}\"\']+/ , :id      , true  , 0,   0, 1], # var_regexp
		[/^\s/                     , :space   , false , 0,   0, 1]  # space_regexp
	]

	@@regexp_array[:C99] =
	[
		# [<reg_exp>, <tag>, <is_necessary>, <min_simularity>, <min_previous_space>, <min_follow_space> ]
		[/^'(\\.|[^'])*'/                   , :quote       , true , 0.1, 0, 1],  # quote1_regexp
		[/^"(\\.|[^"])*"/                   , :quote       , true , 0.1, 0, 1],  # string_regexp
		[/^\/\/.*/                          , :comment     , true , 0.1, 1, 0],  # comment
		[/^\/\*.*?\*\//                     , :comment     , true , 0.1, 1, 0],  # comment
		[/^\/\*.*/                          , :comment     , true , 0.1, 1, 0],  # comment
		[/^[-+]?\d*\.?\d+([eE][-+]?\d+)?/   , :float       , true , 0.1, 0, 1],  # float
		[/^([-+]?\d*\.?\d+)/                , :float       , true , 0.1, 0, 1],  # float
		[/^\*+[[:word:]]+/                  , :ptr         , true , 0.1, 1, 0],  # define
		[/^\&+[[:word:]]+/                  , :ptr         , true , 0.1, 1, 0],  # define
		[/^\#[[:word:]]+/                   , :define      , true , 0.1, 1, 0],  # pointer
		[/^[\;]/                            , :delim       , true , 0.1, 0, 1],  # end of instruction
		[/^[\,]/                            , :comma       , true , 0.1, 0, 1],  # comma
		[/^[\:]/                            , :dpoint      , true , 0.1, 0, 1],  # dpoint
		[/^([\*\/\%\+\-\&\^\|])?\=/         , :assigment   , true , 0.1, 1, 1],  # assigment
		[/^(<<|>>)\=/                       , :assigment   , true , 0.1, 1, 1],  # assigment
		[/^(<<|>>)/                         , :shift       , true , 0.1, 1, 1],  # shift
		[/^(>|<|==|<=|>=|!=)/               , :compare     , true , 0.1, 1, 1],  # compare
		[/^(\|\||\&\&)/                     , :logical     , true , 0.1, 1, 1],  # logical
		[/^(\.|\->)/                        , :postfix     , true , 0.1, 0, 0],  # postfix
		[/^(\-\-|\+\+)/                     , :increm      , true , 0.1, 0, 0],  # increm
		[/^[\&\~\!]/                        , :uoperator   , true , 0.1, 0, 1],  # unary operator
		[/^[\+\-\*\%\/]/                    , :boperator   , true , 0.1, 0, 1],  # binary operator
		[/^[\{\[\(]/                        , :obracket    , true , 0.1, 0, 1],  # open bracket
		[/^[\}\]\)]/                        , :cbracket    , true , 0.1, 0, 1],  # close bracket
		[/^[[:word:]]+/                     , :id          , true , 0.1, 0, 1],  # var_regexp
		[/^[^\w\s]/                         , :spchar      , true , 0, 1, 1],  # spchar_regexp
		[/^\s/                              , :space       , false , 0, 0, 1]   # space_regexp
	]


	@@regexp_array[:java] = 
	[
		# [<reg_exp>, <tag>, <is_necessary>, <min_simularity>, <min_previous_space>, <min_follow_space> ]
		[/^'(\\.|[^'])*'/                   , :quote       , true , 0.1, 0, 1],  # quote1_regexp
		[/^"(\\.|[^"])*"/                   , :quote       , true , 0.1, 0, 1],  # string_regexp
		[/^\/\/.*/                          , :comment     , true , 0.1, 1, 0],  # comment
		[/^\/\*.*?\*\//                     , :comment     , true , 0.1, 1, 0],  # comment
		[/^\/\*.*/                          , :comment     , true , 0.1, 1, 0],  # comment
		[/^[-+]?\d*\.?\d+([eE][-+]?\d+)?/   , :float       , true , 0.1, 0, 1],  # float
		[/^([-+]?\d*\.?\d+)/                , :float       , true , 0.1, 0, 1],  # float
		[/^[\;]/                            , :delim       , true , 0.1, 0, 1],  # end of instruction
		[/^[\,]/                            , :comma       , true , 0.1, 0, 1],  # comma
		[/^[\:]/                            , :dpoint      , true , 0.1, 0, 1],  # dpoint
		[/^([\*\/\%\+\-\&\^\|])?\=/         , :assigment   , true , 0.1, 1, 1],  # assigment
		[/^(<<|>>)\=/                       , :assigment   , true , 0.1, 1, 1],  # assigment
		[/^(<<|>>)/                         , :shift       , true , 0.1, 1, 1],  # shift
		[/^(>|<|==|<=|>=|!=)/               , :compare     , true , 0.1, 1, 1],  # compare
		[/^(\|\||\&\&)/                     , :logical     , true , 0.1, 1, 1],  # logical
		[/^(\.|\->)/                        , :postfix     , true , 0.1, 0, 0],  # postfix
		[/^(\-\-|\+\+)/                     , :increm      , true , 0.1, 0, 0],  # increm
		[/^[\&\~\!]/                        , :uoperator   , true , 0.1, 0, 1],  # unary operator
		[/^[\+\-\*\%\/]/                    , :boperator   , true , 0.1, 0, 1],  # binary operator
		[/^[\{\[\(]/                        , :obracket    , true , 0.1, 0, 1],  # open bracket
		[/^[\}\]\)]/                        , :cbracket    , true , 0.1, 0, 1],  # close bracket
		[/^[[:word:]]+/                     , :id          , true , 0.1, 0, 1],  # var_regexp
		[/^[^\w\s]/                         , :spchar      , true , 0  , 1, 1],  # spchar_regexp
		[/^\s/                              , :space       , false, 0  , 0, 1]   # space_regexp
	]

	def self.type_by_value(value)
		@@regexp_array[@@type].each do |regexp|
			res = regexp[0].match(value);
			if res != nil then
				return regexp[1];
			end
		end
	end

	def self.regexp_array()
		return @@regexp_array[@@type]
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
		return "t"+@tkn_index.to_s + ":"+@value.to_s.red+""
		#return "[ t=" + @type.to_s + " v=" + @value.to_s + "]"
	end
end


class TokenTemplate
	attr_accessor :type, :value, :ltype;

	@@ltype = :default;

	def self.set_ltype(t)
		@@ltype = t;
	end

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
		return "[ t=" + @type.to_s.yellow + " v=" + @value.to_s.green + "] / " +  @except.to_s.red
	end

	def inspect()
		return to_s()
	end

	def cmp(other_token) # compare Token with TokenTemplate
		return !@except.include?(other_token.value) if @type == :any && other_token.type != :eof;
		if @value == :any then
			return @type.is_p_of?(other_token.type, @@ltype) && !@except.include?(other_token.value);
		else
			return @value.include?(other_token.value);
		end 
	end
end