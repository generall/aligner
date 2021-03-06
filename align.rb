require "./staff.rb";
require "./expression.rb"
require "./DP_matcher.rb"
require "./LR_parser"
require "./recreator.rb"


def get_indent(str)
	return "" if str == nil
	indent = str.match(/^\s+/)
	return indent[0] if(indent != nil)
	return "";
end


def test_aligment(input_strings, type)
	p "Lang: " + type.to_s
	
	p = LR_parser.new(type)
	metas  = []
	input_strings.each { |str| metas.push(p.parse_meta(str)); }
	metas.each {|m| m.separate_first!}
	p "metas"
	metas.each {|m| p m.value}
	matcher = DPMatcher.new
	pairs_array = [];

	for i in 0..metas.size-2 do 
		pairs_array.push(matcher.generate_pairs(metas[i].value, metas[i+1].value));
	end

	#p "pairs"
	#pairs_array.each{|x| p x}

	i = 0;
	#p "simularity"
	pairs_array.each do |pairs|
		p matcher.get_percent_simularity([metas[i], metas[i + 1]] , pairs)
		i += 1;
	end
	r = Recreator.new(type)
	r.set_debug false;
	chains = r.generate_chains(pairs_array);
	#p "chains:"
	#chains.each{|ch| p ch}

	#p "reconstruction"
	lines = r.multiline_reconstruction(metas, chains)
	return lines
end

# input
#   input_strings - lines of source code with same indent
#   type - syntax type
#
#
# result
#   aligned lines
#
#
def align_group(input_strings, type)
	p "start align_group" if $DEBUG_project > 0
	p = LR_parser.new(type)
	metas  = [] # tree of meta-expressions
  # meta expression example for default grammar:
  # const int a = (1 + 1);
  #
  # M[ M[ T(const), T(int), T(a) ], T(=), M[ T('('), M[T(1), T(+), T(1)], T(')') ], T(;) ]
  #
  # where
  #   M = meta expression
  #   T = Token
  #
  #Or in formatted view:
  #
  # =
  #   const int a
  #   (
  #     1 + 1
  #   )
  #   ;
  #
  #
  #
	input_strings.each { |str| metas.push(p.parse_meta(str)) }
	metas.each {|m| m.separate_first!} # do not align first token
	matcher = DPMatcher.new
	pairs_array = [] # matched pairs of tokenks for each sequential pair
	
  # pair:
  #
  # [<first_meta_idx>, <second_meta_idx>, [optional submatch pair] ]

  for i in 0..metas.size-2 do 
		pairs_array.push(matcher.generate_pairs(metas[i].value, metas[i+1].value))
  end


	metas.each{|x| x.print_tree } if $DEBUG_project > 1
	r = Recreator.new(type)
	chains = r.generate_chains(pairs_array) # chain of tokens throw lines to allign
	lines = r.multiline_reconstruction(metas, chains) # reconstruct aligned lines from tokens and chains
	return lines
end



#
# input: 
#   input_strings - array of strngs. Each element is source code line
#   type - syntax type
# 
# function splits input_strings into groups with same initial indent
#
#
def align(input_strings, type)
	indents = [];
	for i in 0..input_strings.size-1 do
		input_strings[i] ||= "";
	end

	input_strings.each {|str| indents.push(get_indent(str)); }
	groups = [];
	indent_by_group = [];

	groups.push([input_strings[0]]);
	indent_by_group.push(indents[0]);
	prev_indent = indents[0];

	for i in 1..indents.size-1 do
		if input_strings[i].strip.size == 0 then
				groups.push([""]);
				indent_by_group.push(indents[i]);
				prev_indent = nil;
		else
			if prev_indent == indents[i] then
				groups.last.push(input_strings[i]);
			else
				groups.push([input_strings[i]]);
				indent_by_group.push(indents[i]);
				prev_indent = indents[i]
			end
		end
	end

	puts "groups.size: #{groups.size}"if $DEBUG_project > 0
	result = [];
	groups.each_with_index do |group, i|
		if group.size > 1 then
			group_res = align_group(group, type);
			result   += group_res.map{|x| indent_by_group[i] + x }
		else
			result.push(indent_by_group[i] + group[0].strip)
		end
	end
	return result

end
