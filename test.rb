require "./matcher.rb"

 input_string1 = "p check_prefix_tree(t, [1,3], 2, 2 + 3)";
 input_string2 = "@tokens += [Token.new(res[0], regexp[1], regexp[2], regexp[3])]";


e1 = Expression.new(input_string1);
e2 = Expression.new(input_string2);


matcher = Matcher.new(e1.tokens, e2.tokens);

matcher.erase_insignificant_tokens;
matcher.print_tokens;

matcher.generate_pairs(0.01);
matcher.print_pairs;

matcher.get_intersection
matcher.print_intersections


p "------"
matcher.get_intersection_clusters

p "------"


c = matcher.do_generate_combinations
p matcher.get_pairs_from_combination(c);
