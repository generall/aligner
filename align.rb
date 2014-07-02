require "./staff.rb";
require "./expression.rb"
require "./DP_matcher.rb"
require "./LR_parser"
require "./recreator.rb"


def get_indent(str)
	indent = str.match(/^\s/)
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
	#pairs_array.each{|x| p x}
	r = Recreator.new
	chains = r.generate_chains(pairs_array);
	p "chains:"
	chains.each{|ch| p ch}
	lines = r.multiline_reconstruction(metas, chains)
	return lines
end