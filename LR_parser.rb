require './staff.rb'
require './fsm.rb'
require './expression.rb'

@@Debug = true

class Grammar

	attr_accessor :rules;

	def initialize()
		@rules = {}
	end

	def add_rule(nonterm, product)
		if @rules.has_key?(nonterm) then
			@rules[nonterm] += [product];
		else
			@rules[nonterm]  = [product];
		end
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



#rules: [signal, [[nonterm, [term,term,...], index], [] , ... ] ]
def add_next_vertex(grammar, fsm, rules, vertex_by_set, curr_vertex)
	signal = rules[0];
	r      = rules[1];
	#r = [[nonterm, [term,term,...], index], [] , ... ]
	next_vertex = vertex_by_set[r]
	if next_vertex != nil then
		# vertex exists
		fsm.add_edge(signal, next_vertex, curr_vertex);
	else
		# vertex does not exist

		index_new = fsm.vertex_set.size 
		vertex_by_set[r] = index_new;

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
	return fsm;
end

def parse(fsm, expr)
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
			if acceptable_signals[j] == expr.last then
				is_acceptable = true;
				signal = acceptable_signals[j];
				break;
			end
		end

		if @@Debug then
			p "is_acceptable:   " + is_acceptable .to_s;
			p "signal:          " + signal        .to_s;
			p "expr.last:       " + expr.last     .to_s;
			p "expr:            " + expr          .to_s;
			p "state_stack:     " + state_stack   .to_s;
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
			rule          = fsm.get_value[1];
			to_production = fsm.get_value[0];
			r_s           = rule.size # Rule_Size

			if @@Debug then
				p "apply rule:      " + rule                .to_s;
				p "processed:       " + processed           .to_s;
				p "processed[top]:  " + processed[-r_s..-1] .to_s;
				p "to_production:   " + to_production       .to_s;
			end

			
			if rule == processed[-r_s..-1] then # comparation of arrays by "==" operator
				#
				# some CALLBACK here
				#
				expr.push(to_production)
				fsm.current_vertex = state_stack[-r_s]
				state_stack.pop(r_s)
				processed  .pop(r_s)
			else
				raise "Wrong_production_detected_exception"
			end
		end
		p "-------"

	end
end


grammar =Grammar.new


t1 = [:e, TokenTemplate.new(:spchar, '+'), :t];
t2 = [:t, TokenTemplate.new(:spchar, '*'), :f];
t3 = [TokenTemplate.new(:spchar, '('), :e, TokenTemplate.new(:spchar, ')')]

grammar.add_rule(:main, [:e]);
grammar.add_rule(:e, t1     );
grammar.add_rule(:e, [:t]   );
grammar.add_rule(:t, t2     );
grammar.add_rule(:t, [:f]   );
grammar.add_rule(:f, t3     );
grammar.add_rule(:f, [TokenTemplate.new(:id)]);





grammar_machina = generate_FSM(grammar, [:main, [:e], 0]);

grammar_machina.set_current(0);



grammar_machina.vertex_set.each{
	|x| 
	print x; print " --- ";
	print grammar_machina.get_value(x[0]);
 	print "\n"
} 

p "---"

grammar_machina.get_accepted_signals.each{|x| p x}

print "\n\n\n"

input_string1 = "a+(b+(b*c))";
e1 = Expression.new(input_string1);
e1.erase_insignificant_tokens

expr = e1.tokens.clone
expr += [Token.new(:eof, :eof, true, 0)]

parse(grammar_machina, expr)
