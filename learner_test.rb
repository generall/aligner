require "./learner.rb"

type = :default;
case ARGV[0]
when "C99"
	type = :C99;
when "java"
	type = :java;
end


s = [];

#s.push("@@types_inheritance[:punctuation] = :spchar;");
#s.push("@@types_inheritance[:float      ] = :int;");

learner =  Learner.new(type)

#learner.generate_learning_data(s)

s2 = []


############################
# Insert training data here.
############################

s2.push "class.method = {1, 2, 4, 5};"
s2.push "int y_from;"
s2.push "extern void noize_delete(struct Pixel **matrix, int x, int y);"
s2.push "loadMatrix(\"matrix.ppm\", &matrix, &x, &y);"
s2.push "m2.y_from = y / 2 + 1;"
s2.push "if(0 == matrix[i][j].B)"
s2.push "matrix->matrix[i][j].B = 255;"
s2.push "if(i != matrix->y_from)"
s2.push "*ymass = Ysum / TotalMass;"
s2.push "Ysum += j;"
s2.push "FILE *f = fopen(fname, \"r\");"
s2.push "case State.QLD:city = \"Brisbane\"; break;"
s2.push "matrix[i][j - 1],"

############################
#
############################


s2.each do |str|
	learner.extract_min_space_data(str);
end

learner.generalize();