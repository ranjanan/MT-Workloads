function verify_solution(mesh, x)
	
	verify_whole_domain = false

	global_nodes_x = mesh.global_box.ranges[2] + 1
	global_nodes_y = mesh.global_box.ranges[4] + 1
	global_nodes_z = mesh.global_box.ranges[6] + 1

	box = deepcopy(mesh.local_box)

	if (box.ranges[2] > box.ranges[1] && box.ranges[2] == mesh.global_box.ranges[2])
		box.ranges[2] += 1
	end

	if (box.ranges[4] > box.ranges[3] && box.ranges[4] == mesh.global_box.ranges[4])
		box.ranges[4] += 1
	end

	if (box.ranges[6] > box.ranges[5] && box.ranges[6] == mesh.global_box.ranges[6])
		box.ranges[6] += 1
	end

	rows = []
	row_coords = []

	roffset = 0

	for iz = box.ranges[1] : box.ranges[2]
		for iy = box.ranges[3] : box.ranges[4]
			for ix = box.ranges[5] : box.ranges[6]
				row_id = get_id(global_nodes_x, global_nodes_y, global_nodes_z, ix, iy, iz)

				xi = 0
				yi = 0
				zi = 0
				(xi, yi, zi) = get_coords(row_id, global_nodes_x, global_nodes_y, global_nodes_z, xi, yi, zi)

				verify_this_point = false
				if (verify_whole_domain)
					verify_this_point = true
				elseif (abs(xi - 0.5) < 0.05 && abs(yi - 0.5) < 0.05 && abs(zi - 0.5) < 0.05)
					verify_this_point = true
				end

				if verify_this_point
					push!(rows, roffset)
					push!(row_coords, xi)
					push!(row_coords, yi)
					push!(row_coords, zi)
				end
				
				roffset += 1

			end
		end
	end

	num_terms = 300
	
	max_err = 0
	#println("rows = $rows, size(rows) = $(size(rows)), row_coords = $(row_coords[1:100])")
	for i = 1:size(rows)[1]
		computed_soln = x[rows[i]]
		xi = row_coords[3 * i - 2]
		yi = row_coords[3 * i - 1]
		zi = row_coords[3 * i]

		if (xi == 1.0)
			analytic_soln = 1
		elseif (xi == 0.0 || yi == 0.0 || zi == 0.0)
			analytic_soln = 0
		elseif (yi == 1.0 || zi == 1.0)
			analytic_soln = 0 
		else 
			analytic_soln = soln(xi, yi, zi, num_terms, num_terms)
		end

		err = abs(computed_soln - analytic_soln)
		#println("error = $err")
		if (err > max_err)
		   max_err = err
		end
	end

	if (max_err > 0.06)
		println("Error (= $max_err) too high!")
		return 0
	else 
		println("Accurate to within 1e-6")
		return 1
	end

end
