include("cg_solve.jl")
include("assemble_fe_data.jl")
include("verify_solution.jl")
include("analytical.jl")

function driver(global_box, my_box, params)
   
    const global_nx = global_box.ranges[2]
    const global_ny = global_box.ranges[4]
	const global_nz = global_box.ranges[6]
    
	largest_imbalance = 0
	std_dev = 0    
    compute_imbalance(global_box, my_box, largest_imbalance, std_dev)

	println("Creating/filling mesh . . . ")
    mesh = Mesh([], [], global_box, my_box)
	init_mesh(mesh)

	A = CSRMatrix(false, [], [], [], [], [], 0)

    println("Generating matrix structure . . . ")
	generate_matrix_structure(mesh, A) 

	local_nrows = size(A.rows)[1]
	my_first_row = local_nrows > 0 ? A.rows[1] : -1

	b = zeros(local_nrows)
	x = zeros(local_nrows)

    println("Assembling FE data . . .")
    assemble_fe_data(mesh, A, b, params)

    println("imposing Dirichlet BC . . . ")
    impose_dirichlet(0.0, A, b, global_nx + 1, global_ny + 1, global_nz + 1, mesh.bc_rows_0)
    impose_dirichlet(1.0, A, b, global_nx + 1, global_ny + 1, global_nz + 1, mesh.bc_rows_1)

    println("Making matrix indices local . . .")
    make_local_matrix(A)

	max_iters = 200
	num_iters = 0
	rnorm = 0
	tol = 2.22045e-16  
	verify_result = 0

    println("Starting CG solver . . .") 
    rnorm = cg_solve(A, b, x, max_iters, tol, num_iters, rnorm)

    println("Final resid norm: $rnorm")

    println("Verifying solution at ~ (0.5, 0.5, 0.5) ...")	
    verify_result = verify_solution(mesh, x)
end

function make_local_matrix(A)

	A.num_cols = size(A.rows)[1]
	A.has_local_indices = true

end
function impose_dirichlet(prescribed_value, A, b, global_nx, global_ny, global_nz, bc_rows)

	first_local_row = A.rows[1]
	last_local_row = A.rows[end]

	for i = 1:size(bc_rows)[1]
		row = bc_rows[i]
		#println("row = $row")
		if (row >= first_local_row && row <= last_local_row)
			b[row] = prescribed_value
		end
		zero_row_and_put_1_on_diagonal(A, bc_rows[i])
	end

end

function zero_row_and_put_1_on_diagonal(A, row)

	row_len = 0
	offset, row_len = get_row_pointers(row, A)
	
	#println("offset = $offset")	
	for i = 1:row_len
		if (A.packed_cols[offset + i] == row)
			A.packed_coefs[offset + i] = 1
		else 
			A.packed_coefs[offset + i] = 0
		end
	end

end
function generate_matrix_structure(mesh, A)

	myproc = 0
	
	global_nodes_x = mesh.global_box.ranges[2] + 1
	global_nodes_y = mesh.global_box.ranges[4] + 1
	global_nodes_z = mesh.global_box.ranges[6] + 1

	box = deepcopy(mesh.local_box)

	if (box.ranges[4] > box.ranges[3] && box.ranges[4] == mesh.global_box.ranges[4])
		box.ranges[4] += 1
	end

	if (box.ranges[2] > box.ranges[1] && box.ranges[2] == mesh.global_box.ranges[2])
		box.ranges[2] += 1
	end

	if (box.ranges[6] > box.ranges[5] && box.ranges[6] == mesh.global_box.ranges[6])
		box.ranges[6] += 1
	end

	global_nrows = global_nodes_x * global_nodes_y * global_nodes_z

	nrows = get_num_ids(box)
	
	reserve_space(A, nrows, 27)

	rows = Array(Int64, nrows)
	row_offsets = Array(Int64, nrows + 1)
	row_coords = Array(Int64, nrows * 3)
	
	roffset = 1
	nnz = 0

	for iz = box.ranges[5] + 1: box.ranges[6]
		for iy = box.ranges[3]  + 1: box.ranges[4]
			for ix = box.ranges[1]  + 1: box.ranges[2]

				row_id = get_id(global_nodes_x, global_nodes_y, global_nodes_z, ix, iy, iz)
				rows[roffset] = row_id
				row_coords[3 * roffset - 2] = ix
				row_coords[3 * roffset - 1] = iy
				row_coords[3 * roffset ] = iz
				row_offsets[roffset] = nnz
				roffset  += 1

				for sz = -1:1
					for sy = -1:1
						for sx = -1:1
							col_id = get_id(global_nodes_x, global_nodes_y, global_nodes_z, ix + sx, iy + sy, iz + sz)
							if (col_id > 0 && col_id <= global_nrows)
								nnz +=1
							end
						end
					end
				end

			end
		end
	end
	
	row_offsets[roffset] = nnz
	
	init_matrix(A, rows, row_offsets, row_coords, global_nodes_x, global_nodes_y, global_nodes_z, global_nrows, mesh)
	
end

function init_matrix(M, rows, row_offsets, row_coords, global_nodes_x, global_nodes_y, global_nodes_z, global_nrows, mesh)

	#println("$(row_offsets[1:100])")
	init_mat = MatrixInitOp(rows, row_offsets, row_coords, global_nodes_x, global_nodes_y, global_nodes_z, global_nrows, [], [], [], [], mesh, size(M.rows)[1])
	
	for i = 1:init_mat.n

		push!(init_mat.dest_rows, init_mat.rows[i])
		push!(init_mat.dest_rowoffsets, init_mat.row_offsets[i])
		offset = row_offsets[i]

		ix = init_mat.row_coords[3 * i - 2]
		iy = init_mat.row_coords[3 * i - 1]
		iz = init_mat.row_coords[3 * i]
		nnz = 1

		#println("$offset + $nnz = $(offset+nnz)")
		for sz = -1:1
			for sy = -1:1
				for sx = -1:1
					col_id = get_id(init_mat.global_nodes_x, init_mat.global_nodes_y, init_mat.global_nodes_z, ix + sx, iy + sy, iz + sz)
					#println("$offset + $nnz = $(offset+nnz)")
					if (col_id>0 && col_id <=global_nrows)
						#init_mat.dest_cols[offset + nnz] = col_id
						#init_mat.dest_coefs[offset + nnz] = 0
						push!(init_mat.dest_cols, col_id)
						push!(init_mat.dest_coefs, 0)
						nnz += 1
					end
				end
			end
		end
	#println("offset = $offset")	
	sort_if_needed(init_mat.dest_cols, offset + 1, nnz - 1)

	end
	M.rows = init_mat.rows
	M.row_offsets = init_mat.row_offsets
	M.packed_cols = init_mat.dest_cols
	M.packed_coefs = init_mat.dest_coefs
end

function sort_if_needed(list, offset, list_len)

	need_to_sort = false
	for i = list_len:-1:2
		if (list[i] < list[i-1])
			need_to_sort = true
			break
		end
	end
	if (need_to_sort)
		s = size(list)
		#println("$s")
		#println("offset = $offset , list_len = $list_len")
		a = sort(list[offset:offset + list_len - 1])
		k = 1
		for i = offset:offset + list_len - 1
			list[i] = a[k]
			k += 1
		end
	end

end
function reserve_space(A, nrows, ncols_per_row)

	A.rows = Array(Int64, nrows)
	A.row_offsets = Array(Int64, nrows + 1)
	A.packed_cols = Array(Int64, nrows * ncols_per_row)
	A.packed_coefs = Array(Float64, nrows * ncols_per_row)

end
function init_mesh(mesh)

	max_node_x = mesh.global_box.ranges[2] + 1
	max_node_y = mesh.global_box.ranges[4] + 1
	max_node_z = mesh.global_box.ranges[6] + 1

	const X = 0
	const Y = 1 
	const Z = 2

	x1 = max_node_x - 1
	y1 = max_node_y - 1
	z1 = max_node_z - 1 

	minx = mesh.global_box.ranges[1] + 1
	maxx = mesh.global_box.ranges[2]
	miny = mesh.global_box.ranges[3] + 1
	maxy = mesh.global_box.ranges[4]
	minz = mesh.global_box.ranges[5] + 1
	maxz = mesh.global_box.ranges[6]
	
	# x = 0 face
	for iz = minz:maxz
		for iy = miny:maxy
			nodeID = get_id(max_node_x, max_node_y, max_node_z, 1, iy, iz)
			push!(mesh.bc_rows_0, nodeID)
		end
	end

	# y = 0 face
	for iz = minz:maxz
		for ix = minx:maxx
			nodeID = get_id(max_node_x, max_node_y, max_node_z, ix, 1, iz)
			push!(mesh.bc_rows_0, nodeID)
		end
	end

	# z = 0 face
	for iy = miny:maxz
		for ix = minx:maxx
			nodeID = get_id(max_node_x, max_node_y, max_node_z, ix, iy, 1)
			push!(mesh.bc_rows_0, nodeID)
		end
	end

	# x = 1 face
	for iz = minz:maxz
		for iy = miny:maxy
			nodeID = get_id(max_node_x, max_node_y, max_node_z, 2, iy, iz)
			push!(mesh.bc_rows_1, nodeID)
		end
	end

	# y = 1 face
	for iz = minz:maxz
		for ix = minx:maxx
			nodeID = get_id(max_node_x, max_node_y, max_node_z, ix, 2, iz)
			push!(mesh.bc_rows_0, nodeID)
		end
	end

	# z = 1 face
	for iy = miny:maxy
		for ix = minx:maxx
			nodeID = get_id(max_node_x, max_node_y, max_node_z, ix, iy, 2)
			push!(mesh.bc_rows_0, nodeID)
		end
	end

	#println("bc_rows_0 = $mesh.bc_rows_0")
	
end 

function get_id(nx, ny, nz, x, y, z)

	return x + (nx * (y - 1)) + (nx * ny * (z -1))

end 

function compute_imbalance(global_box, local_box, largest_imbalance, std_dev)
	
	numprocs = 1
	myproc = 0
	local_nrows = get_num_ids(local_box)
	min_nrows = 0
	max_nrows = 0
	global_nrows = 0
	min_proc = myproc
	max_proc = myproc 
	get_global_min_max!(local_nrows, global_nrows, min_nrows, min_proc, max_nrows, max_proc)
	avg_nrows = global_nrows 
	avg_nrows /= numprocs
	largest_imbalance = percentage_difference(min_nrows, avg_nrows)
	tmp = percentage_difference(max_nrows, avg_nrows)
	if (tmp > largest_imbalance)
		largest_imbalance = tmp
	end
	std_dev = compute_std_dev_as_percentage(local_nrows, avg_nrows)
end

function compute_std_dev_as_percentage(local_nrows, avg_nrows)
	#All sorts of MPI stuff
	return 0
end

function percentage_difference(value, average)
	result = abs(value - average)
	if (abs(average) >= 1.e-5)
		result /= average
		result *= 100
	else 
		 result = -1
	end
	return result 
end

function get_num_ids(box)
	return (box.ranges[2] - box.ranges[1])*(box.ranges[4] - box.ranges[3])*(box.ranges[6] - box.ranges[5])
end

function get_global_min_max!(local_n, global_n, min_n, min_proc, max_n, max_proc)
	numprocs = 1 
	myproc = 0
	all_n = zeros(Int64, numprocs, 1)
	all_n[myproc + 1] = local_n
	global_n = 0
	min_n = 5*local_n
	min_proc = 0
	max_n = 0
	max_proc = 0
	for i = 1:numprocs
		global_n += all_n[i]
		if 	(all_n[i] < min_n) 
			min_n = all_n[i]
			min_proc = i - 1
		end
		if (all_n[i] >= max_n)
			max_n = all_n[i]
			max_proc = i - 1
		end
	end
end 
