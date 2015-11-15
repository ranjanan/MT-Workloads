function gen_parents(S, root, rows, cols, nodes, edges, bfs_label)
	ccall((:bfs, "/home/ubuntu/gunrock2/build/lib/libgunrock"), Void, (Ptr{Cint}, Int, Int, Ptr{Cint}, Ptr{Cint}, Int), bfs_label, nodes, edges, rows, cols, root - 1)
	bfs_label += 1
	bfs_label[root] = root
	bfs_label
end
