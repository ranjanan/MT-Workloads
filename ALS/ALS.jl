function main()
	
	A = readdlm("./data/ml-100k/u1.base",'\t';header=false)
	T = readdlm("./data/ml-100k/u1.test",'\t';header=false)
	I = readdlm("./data/movies.csv",',';header=false)

	#The format is userId , movieId , rating
	userCol = round(Int, A[:,1])
	movieCol = round(Int, A[:,2])
	ratingsCol = round(Int, A[:,3])

	userColTest = round(Int, T[:,1])
	movieColTest = round(Int, T[:,2])
	ratingsColTest = round(Int, T[:,3])

	#Create Sparse Matrix
	tempR = sparse(userCol,movieCol,ratingsCol)

	(n_u,n_m)=size(tempR)
	println(n_u)
	println(n_m)

	tempR_t=tempR'

	#Filter out empty movies or users.
	indd_users = trues(n_u)
	println(size(indd_users))
	for u = 1:n_u
		movies = (tempR_t[:,u]).nzind
		if length(movies) == 0
		   indd_users[u]=false
		end
	end

	tempR=tempR[indd_users,:]
	indd_movies=trues(n_m)

	for m = 1:n_m
		users = (tempR[:,m]).nzind
		if length(users) == 0
		   indd_movies[m] = false
		end
	end

	tempR = tempR[:,indd_movies]
	R = tempR
	R_t = R'
	(n_u,n_m) = size(R)

	#Using Parameters lambda and N_f
	#lambda related to regularization and cross validation
	#N_f is the dimension of the feature space
	lambda = 0.065
	N_f = 4

	MM = rand(n_m,N_f-1)
	FirstRow = zeros(Float64,n_m)

	for i=1:n_m
		FirstRow[i]=mean(full(nonzeros(R[:,i])))
	end

	#Update FirstRow as mean of nonZeros of R 
	M = [FirstRow' ; MM']
	(r,c,v) = findnz(R)
	II = sparse(r,c,1)
	locWtU = sum(II,2)
	locWtM = sum(II,1)
	LamI = lambda*eye(N_f)
	U = zeros(n_u,N_f)

	#fix me
	noIters=30

	#The Alternate Least Squares(ALS)
	for i = 1:noIters

		#Preallocation for movies
		M_u = Array(Array{Float64,2}, n_u)
		vector_u = Array(Array{Float64,1}, n_u)
		matrix_u = Array(Array{Float64,2}, n_u)
		for u = 1:n_u
			movies = (R_t[:,u]).nzind
			M_u[u] = M[:, movies] 
			vector_u[u] = M_u[u] * full(R_t[movies, u])
			matrix_u[u] = (M_u[u] * (M_u[u])') + (locWtU[u] * LamI)
		end

		#Update U
		@threads all for u = 1:n_u
			#x = matrix_u[u] \ vector_u[u]
			#U[u,:] = x
			U[u,:] = matrix_u[u] \ vector_u[u]
			#println(round(x,2))
		end

		#Preallocation for users
		U_m = Array(Array{Float64,2}, n_m)
		vector_m = Array(Array{Float64,1}, n_m)
		matrix_m = Array(Array{Float64,2}, n_m)
		for m = 1:n_m
			users = (R[:,m]).nzind
			U_m[m] = U[users, :] 
			vector_m[m] = (U_m[m]') * full(R[users, m])
			matrix_m[m] = ((U_m[m])' * U_m[m]) + (locWtM[m] * LamI)
		end

		#Update M
		for m = 1:n_m
			x = matrix_m[m] \ vector_m[m]
			M[:,m] = x
		 end
	end
	sum(U), sum(M)
end

function recommend(user,n)
    # All the movies sorted in decreasing order of rating.
    top = sortperm(vec(U[user,:]*M))
    # Movies seen by user
    m = find(R[user,:])    
    # unseen_top = setdiff(Set(top),Set(m))
    # To Do: remove the intersection of seen movies.  
    movie_names = readdlm("movies.csv",'\,')
    movie_names[top[1:n,:][:],2]
end
