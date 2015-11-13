function gen_label!(S, root, rows, cols, nodes, edges, bfs_label)
	ccall((:bfs, "/home/ubuntu/gunrock2/build/lib/libgunrock"), Void, (Ptr{Cint}, Int, Int, Ptr{Cint}, Ptr{Cint}, Int), bfs_label, nodes, edges, rows, cols, root - 1)
	bfs_label += 1
	bfs_label[root] = root
end

function gen_and_validate(S, root, v1, v2, rows, cols, nodes, edges, level, t1, t2) 

	tic()
	gen_label!(S, root, rows, cols, nodes, edges, level)
	t1 += toq()
	tic()
	level[root] = 1

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
	t2 += toq()

	return 1, t1, t2
end
