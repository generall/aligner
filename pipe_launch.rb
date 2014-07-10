require "./align.rb"

type = :default;
case ARGV[0]
when "C99"
	type = :C99;
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
