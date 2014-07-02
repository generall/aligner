

@@grammar.add_rule(:main, [:expr    ], [:reducible]);
@@grammar.add_rule(:expr, [:expr, :p], [:reducible]);
@@grammar.add_rule(:expr, [:p       ], [:reducible]);

t1 = [:expr, TokenTemplate.new(['=']), :expr]
@@grammar.add_rule(:expr, t1)
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

@@grammar.add_rule(:t, [TokenTemplate.new(:id                                  )], [:reducible]);
@@grammar.add_rule(:t, [TokenTemplate.new(:quote                               )], [:reducible]);
@@grammar.add_rule(:t, [TokenTemplate.new(:regexp                              )], [:reducible]);
@@grammar.add_rule(:t, [TokenTemplate.new(:spchar,['[','{','(',']','}',')','='])], [:reducible]);


