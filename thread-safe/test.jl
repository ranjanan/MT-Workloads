using Base.Threads
using Base.Test

#a = zeros(Int,10)
a = randperm(10)
a = tsqueue(a)


for i = 1:1000
	a = randperm(10)
	@threads all for i = 1:10
		push!(a, threadid())
	end
	@test size(a,1) == 20
end
