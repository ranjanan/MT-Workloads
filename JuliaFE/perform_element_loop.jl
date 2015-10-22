include("get_elem_nodes.jl")
include("compute_element_matrix_and_vector.jl")
include("sum_into_global_linear_system.jl")
include("Hex8_Enums.jl")
function perform_element_loop(mesh, local_elem_box, A, b, params)
	
	global_elems_x = mesh.global_box.ranges[2]
	global_elems_y = mesh.global_box.ranges[4]
	global_elems_z = mesh.global_box.ranges[6]
 
	elem_data = ElemData(numNodesPerElem, [], [], [], [], [])	
	compute_grad_values!(elem_data.elem_grad_vals)
	num_elems = get_num_ids(local_elem_box)	
	
	elemIDs = Array(Int64, num_elems)
	for i = 1:num_elems
		elemIDs[i] = i
	end

	for i = 1:num_elems
		get_elem_nodes_and_coords(mesh, elemIDs[i], elem_data)
		compute_element_matrix_and_vector(elem_data)
		sum_into_global_linear_system(elem_data, A, b)
	end
end

function get_num_ids(local_elem_box)
	
	nx = local_elem_box.ranges[2] - local_elem_box[1]
	ny = local_elem_box.ranges[4] - local_elem_box[3]
	nz = local_elem_box.ranges[6] - local_elem_box[5]
	
	return nx * ny * nz
	
end

function compute_grad_values!(elem_grad_values)
	gpts = Array(Float64,2)
	gwts = Array(Float64,2)

	gauss_pts(2, gpts, gwts)

	pt = Array(Float64,3)

	for i = 1:2
		pt[1] = gpts[i]
		for j = 1:2
			pt[2] = gpts[j]
			for k = 1:2
				pt[3] = gpts[k]
				gradients!(pt, elem_grad_values)
			end
		end
	end

end

function gradients!(x, elem_grad_values)

	const u = 1.0 - x[1]
	const v = 1.0 - x[2]
	const w = 1.0 - x[3]

	const up1 = 1.0 + x[1]
	const vp1 = 1.0 + x[2]
	const wp1 = 1.0 + x[3]

	#fn 0 
	push!(elem_grad_values, -0.125 * v * w)
	push!(elem_grad_values, -0.125 * u * w)
	push!(elem_grad_values, -0.125 * u * v)

	#fn 1
	push!(elem_grad_values,  0.125 * v * w)
	push!(elem_grad_values, -0.125 * up1 * w)
	push!(elem_grad_values, -0.125 * up1 * v)

	#fn 2
	push!(elem_grad_values,  0.125 * vp1 * w)
	push!(elem_grad_values,  0.125 * up1 * w)
	push!(elem_grad_values, -0.125 * up1 * vp1)

	#fn 3
	push!(elem_grad_values, -0.125 * vp1 * w)
	push!(elem_grad_values,  0.125 * up1 * w)
	push!(elem_grad_values, -0.125 * up1 * vp1)

	#fn 4
	push!(elem_grad_values, -0.125 * v * wp1)
	push!(elem_grad_values, -0.125 * u * wp1)
	push!(elem_grad_values,  0.125 * u * v)

	#fn 5
	push!(elem_grad_values,  0.125 * v * wp1)
	push!(elem_grad_values, -0.125 * up1 * wp1)
	push!(elem_grad_values,  0.125 * up1 * v)

	#fn 6
	push!(elem_grad_values,  0.125 * vp1 * wp1)
	push!(elem_grad_values,  0.125 * up1 * wp1)
	push!(elem_grad_values,  0.125 * up1 * vp1)

	#fn 7
	push!(elem_grad_values, -0.125 * vp1 * wp1)
	push!(elem_grad_values,  0.125 * u * wp1)
	push!(elem_grad_values,  0.125 * u * vp1)
end

function gauss_pts(N, pts, wts)
	const x2 = 1/sqrt(3)
	const x3 = sqrt(3/5)
	const w1 = 5/9
	const w2 = 8/9

	@match N begin
	1 => begin 
			pts[1] = 0
	 		wts[1] = 2.0
	 	 end
	2 => begin 
			pts[1] = -x2
			pts[2] = x2 
			wts[1] = 1.0
			wts[2] = 1.0
		end
	3 => begin
			pts[1] = -x3
			pts[2] = 0.0
			pts[3] = x3
			wts[1] = w1
			wts[2] = w2
			wts[3] = w1
		end
	end
end
