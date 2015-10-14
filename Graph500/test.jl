function test1()
a = Array{Int64,1}[]
push!(a,[1,2,3])
push!(a,[2,3,4])
push!(a,[3,4,5])
push!(a,Int64[])
b = [1,2,3,4,5,6,7,8,9,10]
h = zeros(length(a))
@threads all for i = 1:4
	#page = a[i]
	#if  size(page,1) > 0
	if  size(a[i],1) > 0
		#h[i] = dot(b[page], 1 ./ b[page])
		h[i] = dot(b[a[i]], 1 ./ b[a[i]])
	end
end
end

#function test2()
	a = Array{Int64,1}[]
	push!(a, randperm(100))
	push!(a, randperm(100))
	push!(a, randperm(100))
	push!(a, randperm(100))
	push!(a, randperm(100))
	b = rand(1000)
	c = rand(1000)
	h1 = zeros(length(a))
	@show a
	for i = 1:length(a)
		page = a[i]
		if size(page,1) > 0 
			h1[i] = dot(b[page], 1./ c[page])
		end
	end
	h2 = zeros(length(a))
	@threads all for i = 1:length(a)
		page = a[i]
		if size(page,1) > 0 
			h2[i] = dot(b[page], 1./ c[page])
		end
	end
	assert(h1 == h2)
	@show h1
	@show h2
#end		
