require "./matcher.rb"



 t = Tree::TreeNode.new("root", []);
 
 #p check_prefix_tree(t, [1,2,3,4,5,6,7,8],1, 0)
 #p check_prefix_tree(t, [1,7,8], 1, 0)
 #p check_prefix_tree(t, [1,3,4,8], 1, 0)
 #p check_prefix_tree(t, [1,2,5,6,7,8], 1, 0)
 #p check_prefix_tree(t, [1,7,8], 1, 0)
 #p check_prefix_tree(t, [1,7,8], 2, 0)
 #p check_prefix_tree(t, [2,7,8], 2, 0)
 #p check_prefix_tree(t, [3,7,8], 2, 0)
 #p check_prefix_tree(t, [1,7,8], 2, 0)
 #p check_prefix_tree(t, [6,7,8], 2, 0)
 
# p check_prefix_tree(t, [1,2], 2, 1)
# p check_prefix_tree(t, [1,2], 2, 1)
# p check_prefix_tree(t, [1,2], 2, 1)
# 
#
# p check_prefix_tree(t, [1,2], 2, 2)
# p check_prefix_tree(t, [1,2], 2, 2)
# p check_prefix_tree(t, [1,2], 2, 2)
# 
#
# t.print_tree;
# 
# exit;
# 
# input_string1 = "regexp_array += [\"regexp regexp\"];";
# input_string2 = "test_varible -= [a + b];";

# input_string1 = "+ = ;"
# input_string2 = "; + ="

input_string1 = "= = - + +"
input_string2 = "= = - + +"


# regexp_array       += [\"regexp regexp\"];
# test_varible -= [a + b                  ];

# regexp_array += [\"regexp regexp\"];
# test_varible -= [a + b            ];


e1 = Expression.new(input_string1);
e2 = Expression.new(input_string2);

# e1.tokens.each {|x| p x;}
# p "----------";
# e2.tokens.each {|x| p x;}
# p "==========";

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
#matcher.generate_groups;
#matcher.print_groups;