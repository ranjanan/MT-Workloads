# Graph 500
#
# Driver for this Julia implementation of the Graph 500 benchmarks.
#
# 2014.02.05    kiran.pamnany        Initial code


include("kronecker.jl")
include("makegraph.jl")
include("bfs.jl")
include("validate.jl")
include("output.jl")


function graph500(scale=14, edgefactor=16, num_bfs=64)
    println("Graph 500 (naive Julia version)")

    println("Using Kronecker generator to build edge list...")
    v1, v2 = kronecker(scale, edgefactor)
    println("...done.")

    println("Building graph...")
    tic()
    G = makegraph(v1, v2)
	@show size(G), nnz(G)
    k1_time = toq()
    println("...done.")
	#return

    # generate requested # of random search keys
    N = size(G, 1)
    search = randperm(N)
    search = search[1:num_bfs]

    k2_times = zeros(num_bfs)
    k2_nedges = zeros(num_bfs)
    indeg = hist([v1; v2], 1:N+1)[2]

    println("Running BFSs...")
    run_bfs = 1
    for k = 1:num_bfs
        # ensure degree of search key > 0
        if length(find(G[:, search[k]])) == 0
            #println(@sprintf("(discarding %d)", search[k]))
            continue
        end

        # time BFS for this search key
        tic()
        parents = bfs(G, search[k])
        k2_times[run_bfs] = toq()

        ok = validate(parents, v1, v2, search[k])
        if ok <= 0
            error(@sprintf("BFS %d from search key %d failed to validate: %d",
                           k, search[k], ok))
        end

        k2_nedges[run_bfs] = sum(indeg[parents .>= 0]) / 2
        #println(run_bfs)
        #println(search[k])
        #println(k2_times[run_bfs])
        #println(k2_nedges[run_bfs])
        run_bfs += 1
    end
    println("...done.\n")
    splice!(k2_times, run_bfs:num_bfs)
    splice!(k2_nedges, run_bfs:num_bfs)
    run_bfs -= 1
	@show sum(k2_times)

    println("Output:")
    #output(scale, edgefactor, run_bfs, k1_time, k2_times, k2_nedges)
    TEPS = k2_nedges ./ k2_times
    N = length(TEPS)
    tmp = 1.0./TEPS
    hmean = N/sum(tmp)
    @printf("harmonic_mean_TEPS: %20.17e\n", hmean)
end

