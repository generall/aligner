require "./staff.rb";
require 'json'


def nearest_by_cos(array, params)

	mod2 = params.inject(0){|r,x| r + x**2}

	nearest = array.each_with_index.min_by do |x|
		p = x[0]
		mult = (0...p.count-1).inject(0) {|r, i| r + params[i]*p[i]}
		mod1 = p.inject(0){|r,x| r + x**2}
		dist = mult / Math::sqrt(mod2 * mod1)
		return dist;
	end
	return nearest[1]; # returns nearest index

end

class SpaceConf

	attr_accessor :min_by_type, :max_by_type

	def initialize
		@min_by_type  = {};
		@max_by_type  = {};

		glob_max = 10; # may calculate according to str size

		load();
	end

	def get_min(token1, token2)
		return 0 if token1 == nil || token2 == nil
		ret = @min_by_type[[token1.type, token2.type]]
		if ret == nil
			ret = [token1.min_follow_space, token2.min_previous_space].max
		end
		return ret;
	end

	def get_max(token1, token2, params)
		ret = @max_by_type[[token1.type, token2.type]]
		if ret == nil || ret == []
			ret = glob_max;
		else
			# TODO write some code here
			# find nearest by cos
			# ret format: [ [delta , [params]], ... ]
			params_array = ret.map{|x| x[1]} # all params
			nearest_index = nearest_by_cos(params_array, params);
			return ret[nearest_index][0] # return nearest data
		end
		return ret;
	end

	def save()
		#File.delete("max_by_type.dat");
		#File.delete("min_by_type.dat");

		IO.write("min_by_type.dat", Marshal.dump(@min_by_type));
		IO.write("max_by_type.dat", Marshal.dump(@max_by_type));
	end

	def load()
		@min_by_type = Marshal.load( IO.read( "min_by_type.dat" ) ) if  File.exists?("min_by_type.dat");
		@max_by_type = Marshal.load( IO.read( "max_by_type.dat" ) ) if  File.exists?("max_by_type.dat");
	end

	def to_s()
		s  = "Min:\n";
		@min_by_type.each{|x| s += x.to_s + "\n"}
		s += "Max:\n";
		@max_by_type.each{|x| s += x.to_s + "\n"}
		return s;
	end

end

