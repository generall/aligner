require "./align.rb"


type = :default;
case ARGV[0]
when "C99"
	type = :C99;
end


input_strings = [];

 # input_strings.push("type = type + (a)");
 # input_strings.push("except = except - (b + n)" );
 # input_strings.push("@value = value;");
 # input_strings.push("@value1 = value;" );





	input_strings.push("@@types_inheritance[:C99][:uoperator] = :operator;");
	input_strings.push("@@types_inheritance[:C99][:boperator] = :operator;");




#input_strings.push("index = 0;");

# input_strings.push("info[\"params\"].push(strings[short_str_index].size);")
# input_strings.push("info[\"params\"].push(tokens[long_str_index ][pair[long_str_index ]].str_index);")


lines = align(input_strings, type)

#lines = test_aligment(input_strings, type)

lines.each{|x| p x}

=begin
lines = Recreator.new.reconstruct(m1, m2, pairs);


p lines[0]
p lines[1]
=end