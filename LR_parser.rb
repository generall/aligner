require './staff.rb'
require './fsm.rb'

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
	next_vertex = vertex_by_set[r]
	if next_vertex != nil then
		# vertex exists
		fsm.add_edge(signal, next_vertex, curr_vertex);
	else
		# vertex does not exist

		index_new = fsm.vertex_set.size 
		vertex_by_set[r.clone] = index_new;

		# get completed production rules
		product = nil;
		r.each do |x|
			if x[2] >= x[1].size then
				product = x.clone;
				break;
			end
		end
		fsm.add_vertex(index_new, product);
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


grammar =Grammar.new

grammar.add_rule(:main, [:e]);

t1 = [:e, TokenTemplate.new(:spchar, '+'), :t];

grammar.add_rule(:e, t1 );
grammar.add_rule(:e, [:t] );

t2 = [:t, TokenTemplate.new(:spchar, '*'), :f];

grammar.add_rule(:t, t2   );
grammar.add_rule(:t, [:f] );

t3 = [TokenTemplate.new(:spchar, '('), :e, TokenTemplate.new(:spchar, ')')]

grammar.add_rule(:f, t3);
grammar.add_rule(:f, [TokenTemplate.new(:id)]);

# grammar.closure([[:main, [:e], 0]]).each {|x| p x}
# p "-----"
# grammar.closure([[:e, t3, 1]]).each {|x| p x}
# p "-----"
# grammar.accepted_signals([[:main, [:e], 0]]).each {|x| p x}

p generate_FSM(grammar, [:main, [:e], 0]).vertex_set