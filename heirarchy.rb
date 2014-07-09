
class TypeHierarchy

	@@types_inheritance = {};

	@@types_inheritance[:default] = {}

	@@types_inheritance[:default][:space ] = nil;
	@@types_inheritance[:default][:quote ] = nil;
	@@types_inheritance[:default][:regexp] = nil;
	@@types_inheritance[:default][:id    ] = nil;
	@@types_inheritance[:default][:spchar] = nil;
	@@types_inheritance[:default][:int   ] = nil;
	@@types_inheritance[:default][:punctuation] = :spchar;
	@@types_inheritance[:default][:float      ] = :int   ;
	@@types_inheritance[:default][:int        ] = :id    ;
	@@types_inheritance[:default][:method     ] = :id    ;
	@@types_inheritance[:default][:symbol     ] = :id    ;
	@@types_inheritance[:default][:bracket    ] = :spchar;
	@@types_inheritance[:default][:operator   ] = :spchar;

	@@types_inheritance[:default].default = nil;


	@@types_inheritance[:C99] = {}

	@@types_inheritance[:C99][:float ] = :id ;
	@@types_inheritance[:C99][:ptr   ] = :id ;
	@@types_inheritance[:C99][:define] = :id ;

	@@types_inheritance[:C99][:delim ] = :spchar ;
	@@types_inheritance[:C99][:comma ] = :spchar ;
	@@types_inheritance[:C99][:dpoint] = :spchar ;

	@@types_inheritance[:C99][:assigment] = :dcmp   ;
	@@types_inheritance[:C99][:compare  ] = :dcmp   ;
	@@types_inheritance[:C99][:logical  ] = :dcmp   ;
	@@types_inheritance[:C99][:dcmp     ] = :spchar ;

	@@types_inheritance[:C99][:obracket] = :bracket ;
	@@types_inheritance[:C99][:cbracket] = :bracket ;
	@@types_inheritance[:C99][:bracket ] = :spchar  ;
	
	@@types_inheritance[:C99][:uoperator] = :operator ;
	@@types_inheritance[:C99][:boperator] = :operator ;
	@@types_inheritance[:C99][:operator ] = :spchar;
	@@types_inheritance[:C99].default = nil;


	def self.inheritance(type)
		return @@types_inheritance[type]
	end

	def self.get_parent(child, type)
		return @@types_inheritance[type][child]
	end

end

class Symbol
	def is_p_of?(sym, type)
		t = sym;
		while t != nil do
			return true if t == self;
			t = TypeHierarchy.inheritance(type)[t]
		end
		return false;
	end

	def is_h_of?(sym, type)
		t = self;
		while t != nil do
			return true if t == sym;
			t = TypeHierarchy.inheritance(type)[t]
		end
		return false;
	end
end