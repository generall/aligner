
class TypeHierarchy
	@@types_inheritance = {};

	@@types_inheritance[:space ] = nil;
	@@types_inheritance[:quote ] = nil;
	@@types_inheritance[:regexp] = nil;
	@@types_inheritance[:id    ] = nil;
	@@types_inheritance[:spchar] = nil;

	@@types_inheritance[:bracket ] = :spchar;
	@@types_inheritance[:operator] = :spchar;


	@@types_inheritance.default = nil;

	def self.inheritance()
		return @@types_inheritance
	end

end

class Symbol
	def is_p_of?(sym)
		t = sym;
		while t != nil do
			return true if t == self;
			t = TypeHierarchy.inheritance[t]
		end
		return false;
	end

	def is_h_of?(sym)
		t = self;
		while t != nil do
			return true if t == sym;
			t = TypeHierarchy.inheritance[t]
		end
		return false;
	end
end