require "./align.rb"


input_strings = [];

 # input_strings.push("type = type + (a)");
 # input_strings.push("except = except - (b + n)" );
 # input_strings.push("@value = value;");
 # input_strings.push("@value1 = value;" );




	input_strings.push("1,2,3");
	input_strings.push("1,2,3");



#input_strings.push("index = 0;");

# input_strings.push("info[\"params\"].push(strings[short_str_index].size);")
# input_strings.push("info[\"params\"].push(tokens[long_str_index ][pair[long_str_index ]].str_index);")

lines = test_aligment(input_strings)

lines.each{|x| p x}

=begin
lines = Recreator.new.reconstruct(m1, m2, pairs);


p lines[0]
p lines[1]
=end