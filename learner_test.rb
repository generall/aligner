require "./learner.rb"


s = [];

s.push("@@types_inheritance[:punctuation] = :spchar;");
s.push("@@types_inheritance[:float      ] = :int;");

learner =  Learner.new

learner.generate_learning_data(s)

s2 = []

s2.push "info[\"delta\"] = (tokens1[pair[0]].str_index - tokens2[pair[1]].str_index).abs;"
s2.push "class.method = {1, 2, 4, 5};"
s2.push "@@types_inheritance[:punctuation] = spchar;"
s2.push "case State.QLD : city = \"Brisbane\"; break;"
s2.push "Form2.Image1.canvas.MoveTo(74, 230); Form2.Image1.canvas.LineTo(230, 230);"

s2.each do |str|
	learner.extract_min_space_data(str);
end

learner.generalize();