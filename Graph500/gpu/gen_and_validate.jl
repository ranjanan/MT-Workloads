function gen_and_validate(S, root)
	#S = sprand(10^6, 10^6, 5e-6)
	rows = S.colptr - 1
	cols = S.rowval - 1
	nodes = length(rows) - 1
	edges = length(cols)
	rows = map(Int32, rows)
	cols = map(Int32, cols)
	bfs_label = Array(Int32, nodes)
	ccall((:bfs, "/home/ubuntu/gunrock/build/lib/libgunrock"), Void, (Ptr{Cint}, Int, Int, Ptr{Cint}, Ptr{Cint}, Int), bfs_label, nodes, edges, rows, cols, root - 1)
	bfs_label
end

#function compare()
#	S = sprand(10^4, 10^4, 5e-4)
	
