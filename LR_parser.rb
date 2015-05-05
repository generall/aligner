require './staff.rb'
require './fsm.rb'
require './expression.rb'

require 'colorize'  if $DEBUG_project > 0
require 'pry' if $DEBUG_project > 0

class Grammar

	attr_accessor :rules, :rule_settings;

	def initialize()
    	@Debug = true & false;
		@rules = {}
		@rule_settings = {};
	end

	def add_rule(nonterm, product, settings = [])
		if @rules.has_key?(nonterm) then
			@rules[nonterm] += [product];
		else
			@rules[nonterm]  = [product];
		end
		@rule_settings[[nonterm, product]] = settings;
	end

	#rules: [[non-terminal, [term, term], index], [...]]
	def closure(rules)
		j = rules.map{|x| x.clone};
		all_rules = [];
		@rules .each{ |x,y| y.each{ |z| all_rules += [[x, z, 0]] }}
		j      .each{ |  x| all_rules -= [    x    ] }
		#p all_rules
		begin
			is_added = false;
			j.each do |c_rule|
				if c_rule[1].size >= c_rule[2] then
					nonterm_to_add = c_rule[1][c_rule[2]]
					#p nonterm_to_add
					if nonterm_to_add.class == Symbol then
						temp = [];
						all_rules.each do |rule_to_add|
							#p rule_to_add
							if nonterm_to_add == rule_to_add[0] then
								temp    += [rule_to_add];
								is_added = true;
							end
						end
						all_rules -= temp;
						j         += temp;
					end
				end
			end
		end while is_added
		return j;
	end

	def accepted_signals(rules)
		cl = closure(rules)
		a = {}
		cl.each do |x|
			if x[2] < x[1].size then
				i = x[1][x[2]];
				a[i] == nil ? a[i] = [x] : a[i] += [x];
			end
		end
		return a;
	end

end 

warn_level = $VERBOSE
$VERBOSE = nil;

@@grammar = Grammar.new
@@type = :default;

$VERBOSE = warn_level;



#rules: [signal, [[nonterm, [term,term,...], index], [] , ... ] ]
#vertex_by_set: number of vertex by rule
def add_next_vertex(grammar, fsm, rules, vertex_by_set, curr_vertex)
	signal = rules[0];
	r      = rules[1];
	vertex_index = [];
	r.each do |rule|
		vertex_index += [rule[0], [rule[1][0..rule[2]-1]]];
	end

	#r = [[nonterm, [term,term,...], index], [ ... ] , ... ]
	next_vertex = vertex_by_set[vertex_index]
	if next_vertex != nil then
		# vertex exists
		fsm.add_edge(signal, next_vertex, curr_vertex);
	else
		# vertex does not exist

		index_new = fsm.vertex_set.size 
		vertex_by_set[vertex_index] = index_new;

		# get completed production rules
		product = nil;
		r.each do |x|
			if x[2] >= x[1].size then
				product = x.clone;
				break;
			end
		end
		fsm.add_vertex(index_new, product);

		fsm.add_edge(signal, fsm.vertex_set.size - 1, curr_vertex);

		rules_new = grammar.accepted_signals(r);

		rules_new.each do |rule|
			#increment token index
			for i in 0..rule[1].size-1 do
				rule[1][i][2] += 1;
			end
			add_next_vertex(grammar, fsm, rule, vertex_by_set, index_new);
		end
	end
end


# axiom: [non-terminal, [term, term], 0]
def generate_FSM(grammar, axiom)
	fsm = FSM.new()
	fsm.add_vertex(0, nil)
	vertex_by_set = {};
	vertex_by_set[axiom.clone] = 0;

	rules = grammar.accepted_signals([axiom]);
	# rules: 
	# [ 
	# [signal, [[non-terminal, [term, term, ...], index], [non-terminal, [term, term, ...], index], ...]],
	# [signal, [[non-terminal, [term, term, ...], index], [non-terminal, [term, term, ...], index], ...]],
	# [signal, [[non-terminal, [term, term, ...], index], [non-terminal, [term, term, ...], index], ...]]
	# ]



	rules.each do |rule|
		#increment token index
		for i in 0..rule[1].size-1 do
			rule[1][i][2] += 1;
		end
		add_next_vertex(grammar, fsm, rule, vertex_by_set, 0);
	end

	if @Debug >= 2
		vertex_by_set.each{|x| 
			p x
		} 
	end
	return fsm;
end

class Nonterm
	def initialize(sym = nil, obj = nil, is_reducible = false)
    	@Debug = 0;
		@symbol = sym;
		@object = obj;
		@is_reducible = is_reducible;
	end

	def ==(other)
		if other.class == Nonterm then
			return @symbol == other.symbol;
		else
			if other.class == Symbol then
				return @symbol == other
			end
		end
		return false;
	end

	def !=(other)
		return !(self == other)
	end

	def inspect()
		return to_s()
	end

	def to_s()
		return (":~"+@symbol.to_s).blue
	end

	def print_tree(space = 0)
		return if @object == nil;
		@object.each do |obj|
			if obj.class == Nonterm then
				if @is_reducible then
					obj.print_tree(space)
				else
					# print "-"*space+@symbol.to_s+"\n" 
					obj.print_tree(space + 1)
				end
			else
				print "-"*space+obj.to_s+"\n"
			end
		end
	end

	def make_metaexpr(meta)
		return meta if @object == nil;
		@object.each do |obj|
			if obj.class == Nonterm then
				if @is_reducible then
					obj.make_metaexpr(meta)
				else
					# print "-"*space+@symbol.to_s+"\n" 
					m = MetaExpression.new(meta)
					meta.value += [m]
					obj.make_metaexpr(m)
				end
			else
				meta.value += [obj]
			end
		end
	end
end

def parse(fsm, expr, grammar)
	i = 0;
	processed   = [];
	state_stack = [];
	expr.reverse!
	while expr.last != :main do
		prev_state         = fsm.current_vertex;
		acceptable_signals = fsm.get_accepted_signals;

		is_acceptable = false;
		signal        = nil;
		#
		# may be some sort here
		#
		for j in 0..acceptable_signals.size-1 do
			if acceptable_signals[j] == expr.last || expr.last == acceptable_signals[j] then
				is_acceptable = true;
				signal = acceptable_signals[j];
				break;
			end
		end

		if @Debug >= 2 then
			puts "expr:            " + expr              .to_s;
			puts "signal:          " + signal            .to_s;
			puts "is_acceptable:   " + is_acceptable     .to_s;
			puts "expr.last:       " + expr.last         .to_s;
			puts "state_stack:     " + state_stack       .to_s;
			puts "current_state    " + fsm.current_vertex.to_s;
			puts "processed:       " + processed         .to_s;
		end
		if is_acceptable then
			# edge exists. Symbol accepted
			processed += [expr.last];
			fsm.submit_signal(signal);
			state_stack.push(prev_state);
			expr.pop;
			i+=1;
		else
			# edge does not exists, perform reduction
			if fsm.get_value != nil then
				rule          = fsm.get_value[1];
				to_production = fsm.get_value[0];
				r_s           = rule.size # Rule_Size

				if @Debug >= 2 then
					puts "apply rule:      " + to_production.to_s + " -> " + rule.to_s;
					puts "processed[top]:  " + to_production.to_s + " -> " + processed[-r_s..-1] .to_s;
				end

				is_appropriate = true;
				k = processed.size
				rule.reverse_each do |x|
					k-=1;
					is_appropriate &= x == processed[k] || processed[k] == x;
				end
				
				if is_appropriate then # comparation of arrays by "==" operator
					#
					# some CALLBACK here
					#
					expr.push(Nonterm.new(to_production, processed[-r_s..-1],
						grammar.rule_settings[[to_production, rule]].include?(:reducible)));
					fsm.current_vertex = state_stack[-r_s]
					state_stack.pop(r_s)
					processed  .pop(r_s)
				else

					raise "Wrong_production_detected_exception"
				end
			else
				expr = [(Nonterm.new(:expr, processed + expr.reverse[0..-2], true))];
				processed   = [];
				state_stack = [];
				fsm.current_vertex = 0;
				#raise "no_production_rule_exception"

			end
		end
		p "-------" if @Debug >= 2
	end
	return expr.last;
end

def tree_to_metaexpression(tree, meta)
	if tree.symbol == :expr then

	end
end

class LR_parser
	def initialize(type)
		@Debug = $DEBUG_project

		TokenTemplate.set_ltype type

		warn_level = $VERBOSE
		$VERBOSE = nil;

		@@type = type

		load './grammar.rb'

		$VERBOSE = warn_level;

		@grammar_machina = generate_FSM(@@grammar, [:main, [:expr], 0]);
		@grammar_machina.set_current(0);

		if @Debug >= 2 then
			@grammar_machina.vertex_set.each{
				|x| 
				print x[0]  
				puts ": ";
				x[1].each{|y| puts "  " + y[0].to_s + " => " + y[1].to_s}
				#print @grammar_machina.get_value(x[0]);
				print "\n"
			} 

			p "---"

			@grammar_machina.get_accepted_signals.each{|x| p x}

			print "\n\n\n"
		end
	end

	def parse_meta(input_string, erase_ins = true)
		
		@grammar_machina.set_current(0);

		e = Expression.new(input_string);
		e.erase_insignificant_tokens! if erase_ins
		

		expr = e.tokens.clone
		expr += [Token.new(:eof, :eof, true, 0, 0, 0)]
		
		if @Debug > 0
			print "expr: " 
			p expr
		end

		metaexpr = MetaExpression.new();
		
		ast = parse(@grammar_machina, expr, @@grammar);

		#binding.pry if $DEBUG_project > 0
		ast.print_tree if @Debug > 1

		ast.make_metaexpr(metaexpr);
	

		return metaexpr;
	end
end

