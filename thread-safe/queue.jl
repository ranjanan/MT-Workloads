import Base.push!, Base.pop!, Base.splice!, Base.getindex, Base.setindex!, Base.showarray, Base.size, Base.arrayset
using Base.Threads

type tsqueue{T} <: AbstractArray{T,1}
	data::Vector{T}
	lock::SpinLock
end

function push!{T}(a::tsqueue{T}, b::T)
	lock!(a.lock)
	push!(a.data, b)
	unlock!(a.lock)
end

function tsqueue{T}(a::Vector{T})
	s = SpinLock()
	tsqueue(a,s)
end

function pop!{T}(a::tsqueue{T})
	lock!(a.lock)
	pop!(a.data)
	unlock!(a.lock)
end

function splice!{T}(a::tsqueue{T}, pos::Int64)
	lock!(a.lock)
	splice!(a,pos)
	unlock!(a.lock)
end

function getindex(a::tsqueue, ind::Real)
	a.data[ind]
end

function setindex!(a::tsqueue, v, i)
	#a.data[i] = v
	lock!(a.lock)
	arrayset(a.data, v, i)
	unlock!(a.lock)
end

function showarray{T}(io::IO, a::tsqueue{T})
	print(io, summary(a))
	println(io, ":")
	showarray(io, a.data)
end

function size(a::tsqueue)
	size(a.data)
end
