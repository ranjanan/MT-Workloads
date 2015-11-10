function gen_label!(S, root, rows, cols, nodes, edges, bfs_label)
	ccall((:bfs, "/home/ubuntu/gunrock/build/lib/libgunrock"), Void, (Ptr{Cint}, Int, Int, Ptr{Cint}, Ptr{Cint}, Int), bfs_label, nodes, edges, rows, cols, root - 1)
end

function gen_and_validate(S, root, v1, v2, rows, cols, nodes, edges, level, lv1, lv2, neither_in, both_in, t1, t2, t31, t321, t322)
	tic()
	gen_label!(S, root, rows, cols, nodes, edges, level)
	t1 += toq()
	tic()
	level[root] = 1
	@simd for i = 1:size(level, 1)
		if level[i] > 100000
			level[i] = 0
		end
	end
	t2 += toq()
	tic()
	#lv1 = level[v1]
	#lv2 = level[v2]
	#level = round(Int, level)
	for i = 1:size(v1,1)
		lv1[i] = level[v1[i]]
		lv2[i] = level[v2[i]]
	end
	t31 += toq()
	tic()	
    #neither_in = (lv1 .== 0) & (lv2 .== 0)
    #neither_in = BitArray(size(lv1,1))
	for i = 1:size(lv1,1)
		neither_in[i] = (lv1[i] == 0) & (lv2[i] == 0)
	end
    #both_in = (lv1 .> 0) & (lv2 .> 0)
    #both_in = BitArray(size(lv1,1))
	for i = 1:size(lv1, 1)
		both_in[i] = (lv1[i] > 0) & (lv2[i] > 0)
	end
    #if any(!(neither_in | both_in))
     #   return -4
    #end
	for i = 1:size(lv1, 1)
		if !(neither_in[i] | both_in[i])
			return -4
		end
	end
	t321 += toq()
	tic()
    respects_tree_level = abs(lv1 - lv2) .<= 1
    #if any(!(neither_in | respects_tree_level))
    #    return -5
    #end
	for i = 1:size(lv1, 1)
		if !(neither_in[i] | respects_tree_level[i])
			return -5
		end
	end
	t322 += toq()
	return 1, t1, t2, t31, t321, t322
end
