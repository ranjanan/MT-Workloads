include("kronecker.jl")
include("kernel_1.jl")
include("kernel_2.jl")
include("output.jl")
include("validate.jl")
#function driver()
	SCALE = 10
	edgefactor = 10
	NBFS = 64
	srand(103)
	#ij = kronecker(SCALE, edgefactor)
	ij = int(readdlm("thing.txt", ' '))
	tic()
	G = kernel_1(ij)
	kernel_1_time = toq()
	@show kernel_1_time
	N = size(G,1)
	coldeg = [nnz(G[i,:]) for i = 1:size(G,1)]
	search_key = randperm(N)
	search_key = search_key[!(coldeg[search_key] .== 0)]
	if length(search_key) > NBFS
		search_key = search_key[1:NBFS]
	else
		NBFS = length(search_key)
	end
	search_key = search_key - 1
	kernel_2_time = Inf * ones(NBFS)
	kernel_2_nedge = zeros(NBFS)
	#indeg = hist(ij[:], 1:N)
	for k = 1:NBFS
		tic()
		parent = kernel_2(G, search_key[k])
		kernel_2_time[k] = toq()
		err = validate(parent, ij, search_key[k])
		if err <= 0
			error("BFS $k from search key $(search_key[k]) failed to validate: $err")
		end
	#	kernel_2_nedge[k] = sum(int(indeg[parent >= 0]))/2
	end
	output(SCALE, edgefactor, NBFS, kernel_1_time, kernel_2_time, kernel_2_nedge)
#end
