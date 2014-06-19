# dinamic programming



x = [:a, :t, :g, :c, :c, :c, :c]
y = [:t, :a, :c, :g, :c, :a, :c, :c, :c]
@@cache = {};

def weight(x,y,i,j)
	if(@@cache[[i,j]] != nil) then
		return @@cache[[i,j]][0];
	end

	if x.size == i then
		@@cache[[i,j]] = [0, 3];
		return 0;
	end
	if y.size == j then
		@@cache[[i,j]] = [0, 3];
		return 0;
	end

	value = [];
	value[0] = (x[i]==y[j] ? 1 : 0) + weight(x,y,i+1,j+1)
	value[1] = weight(x, y, i  ,j+1)
	value[2] = weight(x, y, i+1,j  )

	max_value = 0;
	max_index = 0;
	index = 0;
	value.each{
		|x|
		if x > max_value then
			max_value = x;
			max_index = index; 
		end
		index += 1;
	}
	@@cache[[i,j]] = [max_value, max_index];
	return max_value;
end 


p weight(x,y,0,0);

for i in 0..x.size do 
	for j in 0..y.size do 
		print @@cache[[i,j]][0].to_s + " "
	end
	print "\n"
end

print "\n"

for i in 0..x.size do 
	for j in 0..y.size do 
		print @@cache[[i,j]][1].to_s + " "
	end
	print "\n"
end

i = j = 0;
x1 = [];
y1 = [];

curr = @@cache[[i,j]][1]
while curr != 3
	case curr
	when 0 then 
		x1 += [x[i]];
		y1 += [y[j]];
		i+=1;
		j+=1;
	when 1 then
		x1 += [""];
		y1 += [y[j]];
		j+=1;	
	when 2 then
		x1 += [x[i]];
		y1 += [""];
		i+=1;	
	end
	curr = @@cache[[i,j]][1]
end

p x1;
p y1;