# Breadth-first Search
#
# Kernel 2 from the Graph 500 specifications. Builds a BFS
# tree for the given root from the given graph.
#
# 2014.02.05    kiran.pamnany        Initial code
include("queue.jl")

function bfs(G, root)
    # BFS parent information (per-vertex)
    N = size(G, 1)
    parents = zeros(Int64, N)
    parents[root] = root

    # vertex list to visit
    #vlist = zeros(Int64, N)
    vlist = Int[]
    push!(vlist, root)
    rowval = G.rowval
    #vlist = tsqueue(vlist)
    s = SpinLock()
    @threads for k = 1:N
        lock!(s)
        try 
            v = pop!(vlist)
        finally 
            unlock!(s)
        end
        # loop through end vertices for this start vertex
        n = nzrange(G,v)
        for nz in n
            i = rowval[nz]
            # filter out visited vertices
            if parents[i] == 0
                # set the parent for all these end vertices
                parents[i] = v
                #push!(arr, i)
            end
        end
        lock!(s)
        append!(vlist, rowval[n])
        unlock!(s)
    end
    return parents
end
