using Base.Threads

function logreg_parallel(w, labels, points, iterations, N, D)
    temp = similar(labels)
    pw = zeros(N)
    final = zeros(1,D)
    for i in 1:iterations
        A_mul_B!(pw, points, w)
        @threads for i = 1:size(temp, 1)
            temp[i] = (1.0 / (1.0 + exp( -labels[i] * pw[i])) - 1.0) * labels[i]
        end 
        At_mul_B!(final, temp, points)
        for j = 1:size(w, 1)
            w[j] = w[j] - final[j]
        end 
    end
    w
end

function logreg_serial(w, labels, points, iterations)
    for i in 1:iterations
       w -= squeeze(((1.0./(1.0.+exp(-labels.*(points*w))).-1.0).*labels)'*points,1)
    end
    w
end

function driver(iterations::Int)
    D = 10  # Number of dimensions
    N = 10^6
    w::Array{Float64,1} = 2.0.*rand(D)-1.0
    labels = rand(N)
    points = rand(N,D)
    temp = similar(labels)
    pw = zeros(N)
    tserial = @elapsed w1 = logreg_serial(w, labels, points, iterations)
    tparallel = @elapsed  w2 = logreg_parallel(w, labels, points, iterations, N, D)
    println("Time taken by serial implementation = $tserial")
    println("Time taken by parallel implementation = $tparallel")
    println("Speedup over $(nthreads()) threads : $(tserial/tparallel)")
    nothing
end
println("Warm up run : 25 iterations!")
driver(25)
println("Benchmark run : 1000 iterations!")
driver(1000)
