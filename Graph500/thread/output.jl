# Output results
#
# Displays results in the form specified by the Graph 500
# specifications.
#
# 2014.02.05    kiran.pamnany        Initial code


function output(scale, edgefactor, run_bfs, k1_time, k2_times, k2_nedges)
    @printf("SCALE: %d\n", scale)
    @printf("edgefactor: %d\n", edgefactor)
    @printf("NBFS: %d\n", run_bfs)

    @printf("construction_time: %20.17e\n", k1_time)

    @printf("min_time: %20.17e\n", minimum(k2_times))
    @printf("firstquartile_time: %20.17e\n", quantile(k2_times, 0.25))
    @printf("median_time: %20.17e\n", median(k2_times))
    @printf("thirdquartile_time: %20.17e\n", quantile(k2_times, 0.25))
    @printf("max_time: %20.17e\n", maximum(k2_times))
    @printf("mean_time: %20.17e\n", mean(k2_times))
    @printf("stddev_time: %20.17e\n", std(k2_times))

    @printf("min_nedge: %20.17e\n", minimum(k2_nedges))
    @printf("firstquartile_nedge: %20.17e\n", quantile(k2_nedges, 0.25))
    @printf("median_nedge: %20.17e\n", median(k2_nedges))
    @printf("thirdquartile_nedge: %20.17e\n", quantile(k2_nedges, 0.25))
    @printf("max_nedge: %20.17e\n", maximum(k2_nedges))
    @printf("mean_nedge: %20.17e\n", mean(k2_nedges))
    @printf("stddev_nedge: %20.17e\n", std(k2_nedges))

    TEPS = k2_nedges ./ k2_times
    N = length(TEPS)
    tmp = 1.0./TEPS
    hmean = N/sum(tmp)

    tmp -= 1/hmean
    hstddev = (sqrt(sum(tmp .^ 2)) / (N-1)) * hmean^2

    @printf("min_TEPS: %20.17e\n", minimum(TEPS))
    @printf("firstquartile_TEPS: %20.17e\n", quantile(TEPS, 0.25))
    @printf("median_TEPS: %20.17e\n", median(TEPS))
    @printf("thirdquartile_TEPS: %20.17e\n", quantile(TEPS, 0.25))
    @printf("max_TEPS: %20.17e\n", maximum(TEPS))
    @printf("harmonic_mean_TEPS: %20.17e\n", hmean)
    @printf("harmonic_stddev_TEPS: %20.17e\n", hstddev)
end

