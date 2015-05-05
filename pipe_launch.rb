require 'optparse'

$DEBUG_project = 0;

options = {}
OptionParser.new do |opt|
  opt.on('--debug [LEVEL]') { |o| $DEBUG_project = (o || 1).to_i  }
end.parse!

require "./align.rb"


DEBUG_pipe = false
type = :default;
case ARGV[0]
when "C99"
	type = :C99;
when "java"
	type = :java;
end

cmd = STDIN.gets

n = cmd.to_i;
a = [];
for i in 0..n-1 do   
	line = STDIN.gets.split("\n")[0]
	a.push(line)
end

lines = align(a, type)


for i in 0..n-1 do   
	print lines[i] + "\n";
	STDOUT.flush
end
