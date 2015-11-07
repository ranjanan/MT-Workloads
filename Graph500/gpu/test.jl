include("bfs.jl")
include("validate.jl")
include("gen_and_validate.jl")
function test(scale, edgefactor)
    v1, v2 = kronecker(scale, edgefactor)
    G = makegraph(v1, v2)
	@time begin
	parents = bfs(G, 2)
	ok, level1 = validate(parents, v1, v2, 2)
	end
	@time begin 
	level2 = gen_label(G, 2)
	#level2 += 1
	for i = 1:size(level2, 1)
		if level2[i] >  100000
			level2[i] = 0
		end
	end
	end
	#@show level1
	#@show level2
	level1, level2
end
