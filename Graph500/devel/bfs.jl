# Breadth-first Search
#
# Kernel 2 from the Graph 500 specifications. Builds a BFS
# tree for the given root from the given graph.
#
# 2014.02.05    kiran.pamnany        Initial code


function bfs(G, root)
    # BFS parent information (per-vertex)
    N = size(G, 1)
    parents = zeros(Int64, N)
    parents[root] = root

    # vertex list to visit
    vlist = zeros(Int64, N)
    vlist[1] = root

    lastk = 1
	t1 = 0
	t2 = 0
	t3 = 0
	t4 = 0
	t5 = 0
	for k = 1:N
        v = vlist[k]
        if v == 0
            break
        end

        # get a vector of end vertices for this start vertex
		tic()
        I = find(G[:, v])
		t1+= toq()

        # filter out visited vertices
		tic()
        nxt = filter((x) -> parents[x] == 0, I)    
		t2 += toq()

        # set the parent for all these end vertices
		tic()
        parents[nxt] = v
		t3 += toq()		

        # have to visit all these end vertices
		tic()
        vlist[lastk + (1:length(nxt))] = nxt
		t4 += toq()
		tic()
        lastk += length(nxt)
		t5 += toq()
    end
    return parents, t1, t2, t3, t4 , t5
end
