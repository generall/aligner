require "./align.rb"


input_strings = [];

 # input_strings.push("type = type + (a)");
 # input_strings.push("except = except - (b + n)" );
 # input_strings.push("@value = value;");
 # input_strings.push("@value1 = value;" );




	input_strings.push("p = LR_parser.new");
	input_strings.push("metas  = []");
	input_strings.push("   input_strings.each { |str| metas.push(p.parse_meta(str)); }");
	input_strings.push("   metas.each {|m| m.separate_first!}");
	input_strings.push("p \"metas\"");
	input_strings.push("metas.each {|m| p m.value}");
	input_strings.push("");
	input_strings.push("pairs_array = [];");






#input_strings.push("index = 0;");

# input_strings.push("info[\"params\"].push(strings[short_str_index].size);")
# input_strings.push("info[\"params\"].push(tokens[long_str_index ][pair[long_str_index ]].str_index);")

lines = align(input_strings)

lines.each{|x| p x}

=begin
lines = Recreator.new.reconstruct(m1, m2, pairs);


p lines[0]
p lines[1]
=end