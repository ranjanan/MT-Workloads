# Breadth-first Search
#
# Kernel 2 from the Graph 500 specifications. Builds a BFS
# tree for the given root from the given graph.
#
# 2014.02.05    kiran.pamnany        Initial code


function bfs(G, root)
	#tic()
    # BFS parent information (per-vertex)
    N = size(G, 1)
    parents = zeros(Int64, N)
    parents[root] = root
	Gt = G'
	rowptr = map(x -> Int32(x), Gt.colptr)
    colval = map(x -> Int32(x), Gt.rowval)
    nzval = map(x -> Float64(x), Gt.nzval)
    m = Gt.n
    n = Gt.m 
	Gd = CudaSparseMatrixCSR(Float64, CudaArray(rowptr), CudaArray(colval), CudaArray(nzval), (m, n))

    # vertex list to visit
    vlist = zeros(Int64, N)
    vec = zeros(Float64, N)
    vlist[1] = root
	#vec[root] = 1

    lastk = 1
	#t7 = toq()
	t1 = 0
	#t2 = 0
	#t3 = 0
	#t4 = 0
	#t5 = 0
	#t6 = 0
	for k = 1:N
		#tic()
        v = vlist[k]
        if v == 0
            break
        end
		#t6 += toq()

        # get a vector of end vertices for this start vertex
		tic()
        I = find(G[:, v])
		#vec[v] = 1 
		#vd = CudaArray(vec)
		#I = find(to_host(Gd * vd))
		#vec[root] = 0
		t1+= toq()

        # filter out visited vertices
		#tic()
        nxt = filter((x) -> parents[x] == 0, I)    
		#t2 += toq()

        # set the parent for all these end vertices
		#tic()
        parents[nxt] = v
		#t3 += toq()		

        # have to visit all these end vertices
		#tic()
        vlist[lastk + (1:length(nxt))] = nxt
		#t4 += toq()

		#tic()
        lastk += length(nxt)
		#t5 += toq()
    end
    return parents, t1#, t2, t3, t4 , t5, t6, t7 
end
