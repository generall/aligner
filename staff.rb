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
				matrix[i][j] = [
				matrix[i-1][j],
				matrix[i][j-1],
				matrix[i-1][j-1],
				].min + 1
			end
		end
	end
	return matrix.last.last
end

class Token
	attr_accessor :type, :value, :min_simularity, :necessary
	def initialize(value, type, necessary, min_simularity)
		@type = type;
		@value = value;
		@necessary = necessary;
		@min_simularity = min_simularity;
	end
	def cmp(other_token)
		if(@type != other_token.type) then
			return 0;
		else
			max_len = [@value.size, other_token.value.size].max
			return 1.0 - levenshtein(@value, other_token.value).to_f / max_len + other_token.min_simularity;
		end
	end
end

class TokenTemplate
	attr_accessor :type, :value;

	def initialize(type = :any, value = :any)
		@type = type;
		@value = value;
	end

	def cmp(other_token)
		return true if @type == :any && other_token.type != :eof;
		if @value == :any then
			return @type == other_token.type;
		else
			return @type == other_token.type && @value == other_token.value;
		end 
		return false;
	end
end