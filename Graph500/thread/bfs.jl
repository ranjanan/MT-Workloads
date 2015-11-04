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
	rowval = G.rowval

    lastk = 1
    for k = 1:N
        v = vlist[k]
        if v == 0
            break
        end

        # loop through end vertices for this start vertex
        for nz in nzrange(G, v)
            i = rowval[nz]
            # filter out visited vertices
            if parents[i] == 0
                # set the parent for all these end vertices
                parents[i] = v
                lastk += 1
                # have to visit all these end vertices
                vlist[lastk] = i
            end
        end
    end
    return parents
end
