require "./staff.rb";
require "./expression.rb"
require "./DP_matcher.rb"
require "./LR_parser"
require "./recreator.rb"


def get_indent(str)
	indent = str.match(/^\s+/)
	return indent[0] if(indent != nil)
	return "";
end


def test_aligment(input_strings)

	p = LR_parser.new
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

	p "pairs"
	pairs_array.each{|x| p x}

	i = 0;
	p "simularity"
	pairs_array.each do |pairs|
		p matcher.get_percent_simularity([metas[i], metas[i + 1]] , pairs)
		i += 1;
	end
	r = Recreator.new
	chains = r.generate_chains(pairs_array);
	p "chains:"
	chains.each{|ch| p ch}

	p "reconstruction"
	lines = r.multiline_reconstruction(metas, chains)
	return lines
end

# no indent is observed
def align_group(input_strings)
	p = LR_parser.new
	metas  = []
	input_strings.each { |str| metas.push(p.parse_meta(str)); }
	metas.each {|m| m.separate_first!}
	matcher = DPMatcher.new
	pairs_array = [];
	for i in 0..metas.size-2 do 
		pairs_array.push(matcher.generate_pairs(metas[i].value, metas[i+1].value));
	end
	r = Recreator.new
	chains = r.generate_chains(pairs_array);
	lines = r.multiline_reconstruction(metas, chains)
	return lines
end

def align(input_strings)
	indents = [];
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

	result = [];
	groups.each_with_index do |group, i|
		if group.size > 1 then
			group_res = align_group(group);
			result   += group_res.map{|x| indent_by_group[i] + x }
		else
			result.push(indent_by_group[i] + group[0])
		end
	end
	return result

end