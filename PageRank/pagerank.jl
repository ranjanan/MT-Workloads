function pageRank(linkMatrix, alpha = 0.85, convergence = 0.0001, checkSteps = 10)
	incomingLinks, numLinks, leafNodes = transposeLinkMatrix(linkMatrix)
	final = pageRankGenerator(incomingLinks, numLinks, leafNodes, alpha, convergence, checkSteps)
	#return final
end

function API(filename)
	a = readdlm(filename, '\t')
	for i = 1:length(a)
		a[i] += 1
	end
	a= round(Int64,a) 
	links = [Int64[] for i = 1:maximum(a[:,1])]
	for (ind,val) in enumerate(a[:,1])
		push!(links[val], a[ind,2])
	end
	links
	pageRank(links)
end

function transposeLinkMatrix(outGoingLinks)
	nPages = size(outGoingLinks,1)
	incomingLinks = [Int64[] for i = 1:nPages]
	numLinks = zeros(Int, nPages)
	leafNodes = Int64[]
	for i = 1:nPages
		if length(outGoingLinks[i]) == 0
			push!(leafNodes, i)
		else
			numLinks[i] = length(outGoingLinks[i])
			for j in outGoingLinks[i]
				push!(incomingLinks[j], i)
			end
		end
	end
	return incomingLinks, numLinks, leafNodes
end

function pageRankGenerator(At, numLinks, ln, alpha = 0.85, convergence = 0.0001, checkSteps = 10)
	N = length(At)
	M = size(ln,1)
	iNew = ones(N)/N
	iOld = ones(N)/N
	done = false
	while !done
		iNew /= sum(iNew)
		for step = 1:checkSteps
			iOld, iNew = iNew, iOld
			oneIv = (1 - alpha) * sum(iOld) / N
			oneAv = 0.0
			if M > 0
				oneAv = alpha * sum(iOld[ln]) / N
			end
			h = zeros(N)
			@threads for i = 1:N
				#h = 0
				if size(At[i],1) > 0
					#h = alpha * dot(iOld[page], (1 ./ numLinks[page]))
					#h[i] = alpha * dot(iOld[page], (1 ./ numLinks[page]))
					h[i] = alpha * dot(iOld[At[i]], (1 ./ numLinks[At[i]]))
				end
				#iNew[i] = h + oneAv + oneIv
			end
			iNew = h + oneAv + oneIv
		end
		diff = sum(abs(iNew - iOld))
		done = diff < convergence
	end
	return iNew
end
