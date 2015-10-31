# Validate BFS tree
#
# Validates a BFS tree against an edge list.
#
# 2014.02.05    kiran.pamnany        Initial code


function validate(parents, v1, v2, search_key)
    if parents[search_key] != search_key
        return 0
    end
    N = max(maximum(v1), maximum(v2)) + 1

    # indices of all vertices in the tree
    slice = find(parents)

    # vertices' level in the tree
    level = zeros(Int64, size(parents))

    # all the vertices at level 1
    level[slice] = 1
    P = parents[slice]    

    # Descend the tree using P; at each level, all the vertices
    # descended from the search key will be eliminated
    mask = (P .!= search_key)
    k = 0
    while any(mask)
        # these vertices are at the next level
        level[slice[mask]] += 1

        # get all the vertices at this level
        P = parents[P]
        mask = (P .!= search_key)

        # If the level exceeds the maximum vertex value, there
        # must be a cycle in the tree
        k += 1
        if k > N
            return -3
        end
    end

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

    return 1, level
end
