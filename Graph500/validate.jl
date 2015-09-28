function validate(parent, ij, search_key)
	out = 1
	parent = parent + 1
	search_key = search_key + 1
	
	if parent[search_key] != search_key
		out = 0
		return out
	end
	ij = ij + 1
	N = maximum(ij)
	slice = find(parent .> 0)
	level = zeros(size(parent))
	level[slice] = 1
	P = parent[slice]
	mask = P .!= search_key
	k = 0
	while any(mask) 
		level[slice[mask]] = level[slice[mask]] + 1
		P = parent[P]
		mask = P .!= search_key
		k = k + 1
		if k > N
			out = -3
			return out
		end
	end
	lij = level[ij]
	neither_in = (lij[:,1] .== 0) & (lij[:,2] .== 0)
	both_in = (lij[:,1] .> 0) & (lij[:,2] .> 0)
	if any(!(neither_in | both_in))
		out = -4
		return out
	end
	respects_tree_level = abs(lij[:,1] - lij[:,2]) .<= 1
	if any(!(neither_in | respects_tree_level))
		out = -5
		return out
	end
	return out
end
