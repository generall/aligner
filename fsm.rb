class FSM

	attr_accessor :vertex_set, :current_vertex, :values

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

	def get_value(vertex = false)
		vertex = vertex == false ? @current_vertex : vertex;
		return @values[vertex]
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

	def get_accepted_signals()
		return @vertex_set[@current_vertex].keys;
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


