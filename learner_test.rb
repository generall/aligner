require "./learner.rb"


s = [];
s.push("test  = 1;")
s.push("test2 = 2;")


learner =  Learner.new

learner.generate_learning_data(s)

s2 = "info[\"delta\"] = (tokens1[pair[0]].str_index - tokens2[pair[1]].str_index).abs;"

learner.extract_min_space_data(s2);
learner.generalize();