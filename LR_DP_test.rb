require "./align.rb"


type = :default;
case ARGV[0]
when "C99"
	type = :C99;
when "java"
	type = :java;
end


input_strings = [];

 # input_strings.push("type = type + (a)");
 # input_strings.push("except = except - (b + n)" );
 # input_strings.push("@value = value;");
 # input_strings.push("@value1 = value;" );





#input_strings.push("auto string * ololo");
#input_strings.push("string & strong");

#input_strings.push("matrix[i][j].R =255;");
#input_strings.push("matrix[i][j].G =255;");
#input_strings.push("matrix[i][j].B =255;");


input_strings.push("matrix[i - 1][j],");
input_strings.push("matrix[i]j - 1],");
input_strings.push("matrix[i - 1][j - 1],");

#input_strings.push("[/^'(\\.|[^'])*'/                 , :quote       , true , 0.1, 0, 1],  # quote1_regexp");
#input_strings.push("[/^\"(\\.|[^\"])*\"/                 , :quote       , true , 0.1, 0, 1],  # string_regexp");
#input_strings.push("[/^[-+]?\d*\.?\d+([eE][-+]?\d+)?/ , :float       , true , 0.1, 0, 1],  # float");
#input_strings.push("[/^([-+]?\d*\.?\d+)/              , :float       , true , 0.1, 0, 1],  # float");
#input_strings.push("[/^\d+/                           , :int         , true , 0.1, 0, 1],  # integer");
#input_strings.push("[/^[\\.\\,\\;]/                      , :punctuation , true , 0.1, 0, 1],  # punctuation");
#input_strings.push("[/^[\\{\\[\\(\\)\\]\\}]/                , :bracket     , true , 0.1, 0, 1],  # bracket_regexp");
#input_strings.push("[/^[\\=\\+\\-\\*\\&\\^\\~\\|]/            , :operator    , true , 0.1, 0, 1],  # bracket_regexp");
#input_strings.push("[/^[^\\w\\s][[:word:]]+/            , :id          , true , 0.1, 0, 1],  # id");
#input_strings.push("[/^[[:word:]]+/                   , :id          , true , 0.1, 0, 1],  # var_regexp");
#input_strings.push("[/^[^\\w\\s]/                       , :spchar      , true , 0, 0, 1],  # spchar_regexp");
#input_strings.push("[/^\\s/                            , :space       , false , 0, 0, 1]   # space_regexp");


#input_strings.push("index = 0;");

# input_strings.push("info[\"params\"].push(strings[short_str_index].size);")
# input_strings.push("info[\"params\"].push(tokens[long_str_index ][pair[long_str_index ]].str_index);")


#lines = align(input_strings, type)

lines = test_aligment(input_strings, type)

lines.each{|x| puts x}

=begin
lines = Recreator.new.reconstruct(m1, m2, pairs);


p lines[0]
p lines[1]
=end