function cg_solve(A, b, x, max_iters)

    #Initial Residual
    tolerance = 1e-10 
    r = b - A*x
    rtrans = dot(r,r)
    normr = sqrt(rtrans)

    println("Initial residual = $normr")

    k = 1


    while (k<=max_iters && normr>tolerance)
	if (k == 1)
	    d = r
	else 
	    oldtrans = rtrans 
	    rtrans = dot(r,r)
	    beta = rtrans/oldtrans
	    d = r + beta*d
	end
	normr = sqrt(rtrans)
	alpha = 0
	A_d_dot = d'*A*d
	alpha = rtrans/(A_d_dot)[1]
	x = x + alpha*d 
	r = r - alpha*A*d
	num_iters = k
        k = k + 1
    end
    println("x = $x")
    println("num_iters = $k")
    println("final norm = $normr")
end
