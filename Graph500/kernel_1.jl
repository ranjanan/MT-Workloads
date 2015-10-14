function kernel_1(ij)
	ij = ij[!(ij[:,1] .== ij[:,2]),:]
	ij += 1
	N = maximum(ij)
	a = ij[:,1]
	b = ij[:,2]
	G = sparse(a, b, ones(size(ij,1)), N, N)
	G = spones(G+G')
	return G
end
	
