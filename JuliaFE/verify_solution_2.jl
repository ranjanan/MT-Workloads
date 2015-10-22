function verify_solution(mesh, x)

	global_nodes_x = mesh.global_box.ranges[2] + 1
	global_nodes_y = mesh.global_box.ranges[4] + 1
	global_nodes_z = mesh.global_box.ranges[6] + 1

	box = mesh.local_box

	nrows = get_num_ids(box)
	rows = Array(Int64, nrows)
	nrows = Array(Int64, nrows*3)

	roffset = 0

	for iz = box.ranges[1] : box.ranges[2]
		for iy = box.ranges[3] : box.ranges[4]
			for ix = box.ranges[5] : box.ranges[6]
				row_id = get_id(global_nodes_x, global_nodes_y, global_nodes_z, ix, iy, iz)

				x = 0
				y = 0
				z = 0
				(x, y, z) = get_coords(row_id, global_nodes_x, global_nodes_y, global_nodes_z, x, y, z)

				rows[roffset] = ?
				row_coords[3 * roffset - 2] = x
				row_coords[3 * roffset - 1] = y
				row_coords[3 * roffset] = z
				roffset += 1
			end
		end
	end

	num_terms = 300
	
	max_err = 0
	for i = 1:size(rows)
		computed_soln = x.coefs[i]
		xi = row_coords[3 * i - 2]
		yi = row_coords[3 * i - 1]
		zi = row_coords[3 * i]

		if (x == 1.0)
			analytic_soln = 1
		elseif (x == 0.0 || y == 0.0 || z == 0.0)
			analytic_soln = 0
		elseif (y == 1.0 || z == 1.0)
			analytic_soln = 0 
		else 
			analytic_soln = soln(xi, yi, zi, num_terms, num_terms)
		end

		err = abs(computed_soln - analytic_soln)
		if (err > max_err)
		   max_err = err
		end
	end

	if (max_err > 1e-6)
		println("Error too high!")
		return 0
	else 
		println("Accurate to within 1e-6")
		return 1
	end

end
