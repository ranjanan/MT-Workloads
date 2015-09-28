function kronecker(SCALE, edgefactor)
#(SCALE, edgefactor) = (10,10)
	N = 2^SCALE
	M = edgefactor * N 
	(A,B,C) = (0.57, 0.19, 0.19)
	ij = ones(M,2)
	ab = A + B
	c_norm = C / (1 - (A + B))
	a_norm = A / (A + B)
	for ib = 1:SCALE
		ii_bit = rand(M) .> ab
		jj_bit = int(rand(M) .> (c_norm * ii_bit + a_norm * !ii_bit))
		#@show size( 2^(ib-1)), size( [ii_bit; jj_bit]), size(ij)
		ij = ij + 2^(ib-1) * [int(ii_bit) jj_bit]
	end
	p = randperm(N)
	ij = p[ij]
	p = randperm(M)
	ij = ij[p,:]
	ij = ij - 1
end	
		
