# Breadth-first Search
#
# Kernel 2 from the Graph 500 specifications. Builds a BFS
# tree for the given root from the given graph.
#
#include("queue.jl")
using Base.Threads

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
    n = Array(UnitRange{Int64}, N)
    arr = Array(Vector{Int}, N)
    for i = 1:size(arr, 1)
        arr[i] = Int[]
    end
    v = zeros(Int, N)
    check = trues(N)
    is_done = false
    @threads for k = 1:N
        while check[k] 
            try 
                lock!(s)
                v[k] = splice!(vlist, 1) 
            catch 
                unlock!(s)
                if is_done 
                    break   
                end
                continue
            finally 
                unlock!(s)
            end
            check[k] = false
        end
        if is_done 
            break   
        end
        # loop through end vertices for this start vertex
        n[k] = nzrange(G,v[k])
        for nz in n[k]
            #i = rowval[nz]
            # filter out visited vertices
            if parents[rowval[nz]] == 0
                # set the parent for all these end vertices
                lock!(s)
                parents[rowval[nz]] = v[k]
                unlock!(s)
                push!(arr[k], rowval[nz])
            end
        end
        if isempty(arr[k]) && isempty(vlist)
            lock!(s)
            is_done = true
            unlock!(s)
        end
        lock!(s)
        append!(vlist, arr[k])
        unlock!(s)
    end
    return parents
end
