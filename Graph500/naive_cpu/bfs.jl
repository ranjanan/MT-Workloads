# Breadth-first Search
#
# Kernel 2 from the Graph 500 specifications. Builds a BFS
# tree for the given root from the given graph.
#
# 2014.02.05    kiran.pamnany        Initial code


@debug function bfs(G, root)
	@bp
    # BFS parent information (per-vertex)
    N = size(G, 1)
    parents = zeros(Int64, N)
    parents[root] = root

    # vertex list to visit
    vlist = zeros(Int64, N)
    vlist[1] = root

    lastk = 1
    for k = 1:N
        v = vlist[k]
        if v == 0
            break
        end

        # get a vector of end vertices for this start vertex
        I = find(G[:, v])

        # filter out visited vertices
        nxt = filter((x) -> parents[x] == 0, I)    

        # set the parent for all these end vertices
        parents[nxt] = v

        # have to visit all these end vertices
        vlist[lastk + (1:length(nxt))] = nxt
        lastk += length(nxt)
    end
    return parents
end
