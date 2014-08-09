case @@type

when :default
	@@grammar.add_rule(:main, [:expr    ], [:reducible]);
	@@grammar.add_rule(:expr, [:expr, :p], [:reducible]);
	@@grammar.add_rule(:expr, [:p       ], [:reducible]);
	
	t1 = [:expr, TokenTemplate.new(['=']), :expr]
	t2 = [:expr, TokenTemplate.new([',']), :expr]
	
	@@grammar.add_rule(:expr, t1)
	@@grammar.add_rule(:expr, t2)
	@@grammar.add_rule(:p, [:t], [:reducible])
	
	b_open_1  = TokenTemplate.new(['(']);
	b_close_1 = TokenTemplate.new([')']);
	b_open_2  = TokenTemplate.new(['[']);
	b_close_2 = TokenTemplate.new([']']);
	b_open_3  = TokenTemplate.new(['{']);
	b_close_3 = TokenTemplate.new(['}']);
	
	bracket1  = [b_open_1, :expr, b_close_1]
	bracket2  = [b_open_2, :expr, b_close_2]
	bracket3  = [b_open_3, :expr, b_close_3]
	
	bracket4  = [b_open_1       , b_close_1]
	bracket5  = [b_open_2       , b_close_2]
	bracket6  = [b_open_3       , b_close_3]
	
	@@grammar.add_rule(:t, bracket1);
	@@grammar.add_rule(:t, bracket2);
	@@grammar.add_rule(:t, bracket3);
	
	@@grammar.add_rule(:t, bracket4);
	@@grammar.add_rule(:t, bracket5);
	@@grammar.add_rule(:t, bracket6);
	
	@@grammar.add_rule(:t, [TokenTemplate.new(:quote)], [:reducible]);
	@@grammar.add_rule(:t, [TokenTemplate.new(:id   )], [:reducible]);

when :C99
	@@grammar.add_rule(:main, [:expr    ], [:reducible]);
	@@grammar.add_rule(:expr, [:expr, :p], [:reducible]);
	@@grammar.add_rule(:expr, [:p       ], [:reducible]);
	

	t0 = [:type_def, :expr]
	t1 = [:expr, TokenTemplate.new(['=']), :expr]
	t2 = [:expr, TokenTemplate.new([',']), :expr]
	t3 = [:expr, TokenTemplate.new([';']), :expr]

	
	@@grammar.add_rule(:expr, t0, [:reducible])
	@@grammar.add_rule(:expr, t1)
	@@grammar.add_rule(:expr, t2)
	@@grammar.add_rule(:expr, t3)
	@@grammar.add_rule(:p, [:t], [:reducible])
	
	@@grammar.add_rule(:type_def, [:td]);
	
	@@grammar.add_rule(:td, [:type_spec, :td]       , [:reducible])
	@@grammar.add_rule(:td, [:type_spec, :true_type], [:reducible])


	sp_words = ['auto', 'register', 'static', 'long', 'extern', 'typedef', 'const', 'volatile', 'struct'];

	spec = [TokenTemplate.new(sp_words)];



	@@grammar.add_rule(:type_spec, spec, [:reducible]);

	ttype1 = [TokenTemplate.new(["*"])]
	ttype2 = [TokenTemplate.new(["&"])]
	ttype3 = [TokenTemplate.new(:ptr)]
	ttype4 = [:id]


	@@grammar.add_rule(:true_type, ttype1, [:reducible]);
	@@grammar.add_rule(:true_type, ttype2, [:reducible]);
	@@grammar.add_rule(:true_type, ttype3, [:reducible]);
	@@grammar.add_rule(:true_type, ttype4, [:reducible]);

	idtmp = [TokenTemplate.new(:id, sp_words)]
	@@grammar.add_rule(:id, idtmp, [:reducible]);

	b_open_1  = TokenTemplate.new(['(']);
	b_close_1 = TokenTemplate.new([')']);
	b_open_2  = TokenTemplate.new(['[']);
	b_close_2 = TokenTemplate.new([']']);
	b_open_3  = TokenTemplate.new(['{']);
	b_close_3 = TokenTemplate.new(['}']);
	
	bracket1  = [b_open_1, :expr, b_close_1]
	bracket2  = [b_open_2, :expr, b_close_2]
	bracket3  = [b_open_3, :expr, b_close_3]
	
	bracket4  = [b_open_1       , b_close_1]
	bracket5  = [b_open_2       , b_close_2]
	bracket6  = [b_open_3       , b_close_3]
	
	@@grammar.add_rule(:t, bracket1);
	@@grammar.add_rule(:t, bracket2);
	@@grammar.add_rule(:t, bracket3);
	
	@@grammar.add_rule(:t, bracket4);
	@@grammar.add_rule(:t, bracket5);
	@@grammar.add_rule(:t, bracket6);
	
	@@grammar.add_rule(:t, [:id                        ] , [:reducible]);
	@@grammar.add_rule(:t, [TokenTemplate.new(:quote  )] , [:reducible]);
	@@grammar.add_rule(:t, [TokenTemplate.new(:comment)] , [:reducible]);
	@@grammar.add_rule(:t, [TokenTemplate.new(:float  )] , [:reducible]);
	
	@@grammar.add_rule(:t, [TokenTemplate.new(:spchar , ['[', '{', '(', ']', '}', ')', '=', ',', ';'])] , [:reducible]);

when :java

	@@grammar.add_rule(:main, [:expr    ], [:reducible]);
	@@grammar.add_rule(:expr, [:expr, :p], [:reducible]);
	@@grammar.add_rule(:expr, [:p       ], [:reducible]);
	

	t0 = [:type_def, :expr]
	t1 = [:expr, TokenTemplate.new(['=']), :expr]
	t2 = [:expr, TokenTemplate.new([',']), :expr]
	t3 = [:expr, TokenTemplate.new([';']), :expr]

	
	@@grammar.add_rule(:expr, t0, [:reducible])
	@@grammar.add_rule(:expr, t1)
	@@grammar.add_rule(:expr, t2)
	@@grammar.add_rule(:expr, t3)
	@@grammar.add_rule(:p, [:t], [:reducible])
	
	@@grammar.add_rule(:type_def, [:td]);
	
	@@grammar.add_rule(:td, [:type_spec, :td]       , [:reducible])
	@@grammar.add_rule(:td, [:type_spec, :true_type], [:reducible])


	sp_words = ["public",  "protected", "private", "static",
		 "final", "transient", "volatile", "abstract", "synchronized", "native"];

	spec = [TokenTemplate.new(sp_words)];

	@@grammar.add_rule(:type_spec, spec, [:reducible]);

	ttype4 = [:id]

	@@grammar.add_rule(:true_type, ttype4, [:reducible]);

	idtmp = [TokenTemplate.new(:id, sp_words)]
	@@grammar.add_rule(:id, idtmp, [:reducible]);

	b_open_1  = TokenTemplate.new(['(']);
	b_close_1 = TokenTemplate.new([')']);
	b_open_2  = TokenTemplate.new(['[']);
	b_close_2 = TokenTemplate.new([']']);
	b_open_3  = TokenTemplate.new(['{']);
	b_close_3 = TokenTemplate.new(['}']);
	
	bracket1  = [b_open_1, :expr, b_close_1]
	bracket2  = [b_open_2, :expr, b_close_2]
	bracket3  = [b_open_3, :expr, b_close_3]
	
	bracket4  = [b_open_1       , b_close_1]
	bracket5  = [b_open_2       , b_close_2]
	bracket6  = [b_open_3       , b_close_3]
	
	@@grammar.add_rule(:t, bracket1);
	@@grammar.add_rule(:t, bracket2);
	@@grammar.add_rule(:t, bracket3);
	
	@@grammar.add_rule(:t, bracket4);
	@@grammar.add_rule(:t, bracket5);
	@@grammar.add_rule(:t, bracket6);
	
	@@grammar.add_rule(:t, [:id                        ] , [:reducible]);
	@@grammar.add_rule(:t, [TokenTemplate.new(:quote  )] , [:reducible]);
	@@grammar.add_rule(:t, [TokenTemplate.new(:comment)] , [:reducible]);
	@@grammar.add_rule(:t, [TokenTemplate.new(:float  )] , [:reducible]);
	
	@@grammar.add_rule(:t, [TokenTemplate.new(:spchar , ['[', '{', '(', ']', '}', ')', '=', ',', ';'])] , [:reducible]);


end

