function cg_solve(A, b, x, max_iter, tolerance, num_iters, normr)

	my_proc = 0
	if (A.has_local_indices == false)
		println("Error! in cg_solve")
	end
	
	nrows = size(A.rows)
	ncols = A.num_cols

	r = zeros(nrows)
	#r = deepcopy(b)
	p = zeros(ncols)	
	Ap = zeros(nrows)
	#Ap = deepcopy(b)

	normr = 0
	rtrans = 0
	oldrtrans = 0
	
	print_freq = max_iter/10
	
	one = 1.0
	zero = 0.0

	p = (one * x) + (zero * x)

	matvec(A, p, Ap)
	println("Ap sum = $(sum(Ap))")
	
	r = (one * b) + (-one * Ap)	

	rtrans = sum(r.*r)
	
	normr = sqrt(rtrans)

	if (my_proc == 0)
		println("Initial Residual = $normr")
	end

	brkdown_tol = tolerance 

	for k = 1:max_iter

		if (k == 1) 
			p = (one * r) + (zero * r)
		else
			oldtrans = rtrans
			rtrans = sum(r.*r)
			beta = rtrans/oldrtrans
			p = (one * r) + (beta * p)
		end
	
		normr = sqrt(rtrans)

		if (my_proc == 0 && (k % print_freq == 0 || k == max_iter))
			println("Iteration = $k, Residual = $normr")
		end

		alpha = 0
		p_ap_dot = 0

		matvec(A, p, Ap)
		
		p_ap_dot = sum(Ap .* p)

		if (p_ap_dot < brkdown_tol) 
			if (p_ap_dot < 0)
				println("Error in cg_solve loop!")
			end
		else
			brkdown_tol = 0.1 * p_ap_dot
		end
		
		alpha = rtrans/p_ap_dot
	
		x = (one * x) + (alpha * p)
		r = (one * r) + (-alpha * Ap)
	
		if (normr < 0.06)
			println("Broken! k = $k, normr = $normr")
			break
		end
	end

	#println("iter = $iter")
	return normr 

end

function matvec(A, x, y)

	n = size(A.rows)[1]
	Arowoffsets = A.row_offsets
	Acols = A.packed_cols
	Acoefs = A.packed_coefs
	
	xcoefs = x
	ycoefs = y
	beta = 0
	sum = 0

	for row = 1:n
		sum = beta * ycoefs[row]

		for i = 1 + Arowoffsets[row]: Arowoffsets[row + 1]
			sum += Acoefs[i] * xcoefs[Acols[i]]
		end
		#if sum > 0
			#println("sum isn't zero = $sum")
			#println("Therefore, sum = $sum")
		#end
		ycoefs[row] = sum
	end
	#return y

end
