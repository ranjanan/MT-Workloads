# Kronecker Generator
#
# Based on the generator from the Graph 500 specifications. Outputs
# an edge list in two arrays, with the start vertices in the first
# array and the end vertices in the second.
#
# 2014.02.05    kiran.pamnany        Initial code


function kronecker(scale, edge_factor)
    N = 1 << scale                # number of vertices
    M = edge_factor*N             # number of edges

    A, B, C = 0.57, 0.19, 0.19    # initiator parameters

    # vertex arrays (edge list)
    v1 = ones(M)
    v2 = ones(M)

    ab = A + B
    c_norm = C/(1-(A+B))
    a_norm = A/(A+B)

    # distribute edges
    for ib = 1:scale
        v1_bit = (rand(M) .> ab) + 0
        v2_bit = (rand(M) .> (c_norm*v1_bit + a_norm*(abs(v1_bit-1)))) + 0
        v1 += (1 << (ib-1)) * v1_bit
        v2 += (1 << (ib-1)) * v2_bit
    end

    # permute vertex labels
    p = randperm(N)
    v1 = p[v1]
    v2 = p[v2]

    # permute the edge list
    p = randperm(M)
    v1 = v1[p]
    v2 = v2[p]

    return (v1, v2)
end
