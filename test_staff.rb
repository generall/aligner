class A
	attr_accessor :a,:b;
	def initialize()
		@a=@b=0;
	end

	def ==(other)
		return @a == other.a && @b == other.b
	end
end

a = A.new
b = A.new


p a==b;
p a.eql? b;
p a.equal? b;
p [a] == [b];

exit;