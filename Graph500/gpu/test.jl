include("bfs.jl")
include("kronecker.jl")
include("validate.jl")
include("gen_and_validate.jl")
function test(scale, edgefactor)
    v1, v2 = kronecker(scale, edgefactor)
    G = makegraph(v1, v2)
	#@time begin
	parents = bfs(G, 2)
	ok, level1 = validate(parents, v1, v2, 2)
	#end
	rows = G.colptr - 1
	cols = G.rowval - 1
	nodes = length(rows) - 1
	edges = length(cols)
	rows = map(Int32, rows)
	cols = map(Int32, cols)
	bfs_label = zeros(Int32, nodes)
	#level2 = gen_label(G, 2)
	gen_label!(S, 2, rows, cols, nodes, edges, bfs_label)
	bfs_label += 1
	bfs_label[2] = 2
	#for i = 1:size(bfs_label,1)
	#	if bfs_label[i] < 0
	#		bfs_label[i] = 0
	#	end
	#end
	ok, level2 = validate(bfs_label, v1, v2, 2)
	#level2 += 1
	#for i = 1:size(bfs_label, 1)
	#	if bfs_label[i] >  100000
	#		bfs_label[i] = 0
	#	end
	#end
	#@show level1
#@show level2
	parents, level1, bfs_label
end
