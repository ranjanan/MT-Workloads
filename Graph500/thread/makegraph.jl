# Graph Construction
#
# Kernel 1 from the Graph 500 specifications. Given an edge list
# in the form of two arrays of vertices, constructs a graph in
# sparse matrix format.
#
# 2014.02.05    kiran.pamnany        Initial code


function makegraph(v1, v2)
    # remove self-edges and find the maximum label
    N = 0
    cnt = 1
    for i in 1:length(v1)
        if v1[i] != v2[i]
            v1[cnt] = v1[i]
            v2[cnt] = v2[i]
            N = max(N, v1[cnt], v2[cnt])
            cnt = cnt + 1
        end
    end
    splice!(v1, cnt:length(v1))
    splice!(v2, cnt:length(v2))

    # create a square sparse matrix
    G = sparse(v2, v1, ones(Int8, length(v2)), N, N)

    # symmetrize to model an undirected graph
    G = spones(G + G.')

    return G
end
