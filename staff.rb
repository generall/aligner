require 'set'

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

class Token
	attr_accessor :type, :value, :min_simularity, :necessary, :min_follow_spase, :min_previous_spase;

	def initialize(value, type, necessary, min_simularity, min_previous_spase, min_follow_spase)
		@type               = type;
		@value              = value;
		@necessary          = necessary;
		@min_simularity     = min_simularity;
		@min_previous_spase = min_previous_spase;
		@min_follow_spase   = min_follow_spase
	end

	def cmp(other_token)
		if other_token.class != Token then
			return 0
		end

		if(@type != other_token.type) then
			return 0;
		else
			max_len = [@value.size, other_token.value.size].max
			return 1.0 - levenshtein(@value, other_token.value).to_f / max_len + other_token.min_simularity;
		end
	end

	def to_s()
		return ""+@value.to_s+""
		#return "[ t=" + @type.to_s + " v=" + @value.to_s + "]"
	end
end


class TokenTemplate
	attr_accessor :type, :value;

	def initialize(type = :any, value = :any, except = [])
		@type   = type;
		@value  = value;
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

	def cmp(other_token)
		return !@except.include?(other_token.value) if @type == :any && other_token.type != :eof;
		if @value == :any then
			return @type == other_token.type && !@except.include?(other_token.value);
		else
			return @type == other_token.type && @value.include?(other_token.value);
		end 
	end
end