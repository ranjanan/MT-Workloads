using Base.Threads
using Base.Test

#include("queue.jl")
#a = zeros(Int,10)
a = randperm(10)
a = tsqueue(a)


for j = 1:1000
	a = tsqueue(randperm(10))
	@threads for i = 1:10
		push!(a, threadid())
	end
	@test size(a,1) == 20
end
