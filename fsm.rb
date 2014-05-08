class FSM

	attr_accessor :vertex_set, :current_vertex

	def initialize()
		@vertex_set     = {} ;
		@values         = {} ;
		@current_vertex = nil;
	end

	def add_vertex(new_vertex, value = nil)
		@vertex_set [new_vertex] = {};
		@values     [new_vertex] = value;
	end

	#--------------

	def add_value(vertex, value)
		@values[vertex] = value;
	end

	def get_value()
		return @values[@current_vertex]
	end


	#---------------

	def add_edge(signal, to_v, from_v = false)
		from_v = from_v == false ? @current_vertex : from_v;  
		@vertex_set[from_v][signal] = to_v;
	end

	def set_current(vertex)
		if @vertex_set.has_key?(vertex) then
			@current_vertex = vertex
			return true;
		else
			return false;
		end
	end

	def submit_signal(signal)
		if @vertex_set[@current_vertex].has_key?(signal) then
			@current_vertex =  @vertex_set[@current_vertex][signal];
			return true;
		else
			return false;
		end
	end
end


