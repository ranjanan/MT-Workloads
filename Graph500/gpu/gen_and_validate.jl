function gen_label(S, root)
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

function gen_and_validate(S, root, v1, v2)
	level = gen_label(S, root)
	level[root] = 1
	for i = 1:size(level, 1)
		if level[i] > 100000
			level[i] = 0
		end
	end
	lv1 = level[v1]
	lv2 = level[v2]
	
    neither_in = (lv1 .== 0) & (lv2 .== 0)
    both_in = (lv1 .> 0) & (lv2 .> 0)
    if any(!(neither_in | both_in))
        return -4
    end
    respects_tree_level = abs(lv1 - lv2) .<= 1
    if any(!(neither_in | respects_tree_level))
        return -5
    end
	
	return 1
end
