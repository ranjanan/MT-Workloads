# Breadth-first Search
#
# Kernel 2 from the Graph 500 specifications. Builds a BFS
# tree for the given root from the given graph.
#
# 2014.02.05    kiran.pamnany        Initial code
include("bfs_hack.jl")

function bfs(G, root)
	#G = Graph(G)
	parents = bfs_gen(G, root)
    return parents
end
