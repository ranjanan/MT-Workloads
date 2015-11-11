include("../naive_cpu/graph500.jl")
function run_benchmarks()
	graph500(10,10)
	
	println("Starting benchmarks ...")
	for i = 10 : 20
		println("k = $i")
		graph500(15, i)
	end

	for i = 10 : 20
		println("k = $i")
		graph500(i, 15)
	end
	println("Done.")
end
