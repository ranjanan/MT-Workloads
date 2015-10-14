function kernel_2(G, root)
	N = size(G,1)
	root = root + 1
	parent = zeros(N)
	parent[root] = root
	vlist = zeros(Int, N)
	vlist[1] = root
	lastk = 1
	for k = 1:N
		v = vlist[k]
		if v == 0
			break
		end
		(I,J,V) = findnz(G[:,v])
		nxt = I[parent[I] .== 0]
		parent[nxt] = v
		vlist[lastk + collect(1:length(nxt))] = nxt
		lastk = lastk + length(nxt)
	end
	parent = parent - 1
end
