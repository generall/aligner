require "./learner.rb"


s = [];

s.push("@@types_inheritance[:punctuation] = :spchar;");
s.push("@@types_inheritance[:float      ] = :int;");

learner =  Learner.new

learner.generate_learning_data(s)

s2 = "info[\"delta\"] = (tokens1[pair[0]].str_index - tokens2[pair[1]].str_index).abs;"
learner.extract_min_space_data(s2);

s2 = "class.method = {1, 2, 4, 5};"
learner.extract_min_space_data(s2);

s2 = "@@types_inheritance[:punctuation] = spchar;"
learner.extract_min_space_data(s2);

s2 = "case State.QLD : city = \"Brisbane\"; break;"
learner.extract_min_space_data(s2);


learner.generalize();