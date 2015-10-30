using LightGraphs
function bfs_gen(G::Graph, root)
	nvg = nv(G)
	visitor = LightGraphs.TreeBFSVisitorVector(nvg)
    LightGraphs.bfs_tree!(visitor, G, root)
	visitor.tree
end
