class DPMatcher
	def initialize()
		@cache = {};

	end

	def match(x,y,i,j)
		if(@cache[[i,j]] != nil) then
			return @cache[[i,j]][0];
		end

		if x.size == i then
			@cache[[i,j]] = [0, 3];
			return 0;
		end
		if y.size == j then
			@cache[[i,j]] = [0, 3];
			return 0;
		end

		value = [];
		value[0] = x[i].cmp(y[j]) + match(x,y,i+1,j+1)
		value[1] = match(x, y, i  ,j+1)
		value[2] = match(x, y, i+1,j  )

		max_value = 0;
		max_index = 0;
		index = 0;
		value.each{
			|x|
			if x > max_value then
				max_value = x;
				max_index = index; 
			end
			index += 1;
		}
		@cache[[i,j]] = [max_value, max_index];
		return max_value;
	end

	def get_pairs(x,y, start = 0)
		@cache = {};
		match(x, y, start, start);
		pairs = [];
		i = j = start;
		curr  = @cache[[i,j]][1]
		while curr != 3
			case curr
			when 0 then
				pairs += [[i,j]] if x[i].cmp(y[j]) > Float::EPSILON
				i+=1;
				j+=1;
			when 1 then
				j+=1;	
			when 2 then
				i+=1;	
			end
			curr = @cache[[i,j]][1]
		end
		return [@cache[[start, start]][0], pairs];
	end
end

