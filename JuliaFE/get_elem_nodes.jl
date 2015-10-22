function get_elem_nodes_and_coords(mesh, elemID, elem_data)

	get_elem_nodes_and_coords(mesh, elemID, elem_data.elem_node_ids, elem_data.elem_node_coords)	
end
function get_elem_nodes_and_coords(mesh, elemID, node_ords, node_coords)
	
	const global_nodes_x = mesh.global_box.ranges[2] + 1
	const global_nodes_y = mesh.global_box.ranges[4] + 1
	const global_nodes_z = mesh.global_box.ranges[6] + 1

	elem_int_x = 0
	elem_int_y = 0
	elem_int_z = 0

	(elem_int_x, elem_int_y, elem_int_z) = get_int_coords(elemID, global_nodes_x - 1, global_nodes_y - 1, global_nodes_z - 1)
	#println("x = $elem_int_x, y = $elem_int_y, z = $elem_int_z")
	nodeID = get_id(global_nodes_x, global_nodes_y, global_nodes_z, elem_int_x, elem_int_y + 1, elem_int_z + 1)
	#println("nodeID = $nodeID")

	get_hex_node_ids(global_nodes_x, global_nodes_y, nodeID, node_ords)

	global_elems_x = mesh.global_box.ranges[2]
	global_elems_y = mesh.global_box.ranges[4]
	global_elems_z = mesh.global_box.ranges[6]

	ix = 0
	iy = 0
	iz = 0
	(ix, iy, iz) = get_coords(nodeID, global_nodes_x, global_nodes_y, global_nodes_z, ix, iy, iz)
	#println("ix = $ix, iy = $iy, iz = $iz")

	ix += 1
	iy += 1
	iz += 1

	hx = 1.0/global_elems_x
	hy = 1.0/global_elems_y 
	hz = 1.0/global_elems_z

	get_hex8_node_coords(ix, iy, iz, hx, hy, hz, node_coords)

end

function get_hex8_node_coords(x, y, z, hx, hy, hz, elem_node_coords)

	push!(elem_node_coords, x)
	push!(elem_node_coords, y)
	push!(elem_node_coords, z)

	push!(elem_node_coords, x + hx)
	push!(elem_node_coords, y)
	push!(elem_node_coords, z)

	push!(elem_node_coords, x + hx)
	push!(elem_node_coords, y + hy)
	push!(elem_node_coords, z)

	push!(elem_node_coords, x)
	push!(elem_node_coords, y + hy)
	push!(elem_node_coords, z)

	push!(elem_node_coords, x)
	push!(elem_node_coords, y)
	push!(elem_node_coords, z + hz)

	push!(elem_node_coords, x + hx)
	push!(elem_node_coords, y)
	push!(elem_node_coords, z + hz)

	push!(elem_node_coords, x + hx)
	push!(elem_node_coords, y + hy)
	push!(elem_node_coords, z + hz)

	push!(elem_node_coords, x)
	push!(elem_node_coords, y + hy)
	push!(elem_node_coords, z + hz)

end
function get_coords(ID, nx, ny, nz, x, y, z)

	const xdiv = nx>1 ? nx - 1 : 1
	const ydiv = ny>1 ? ny - 1 : 1
	const zdiv = nz>1 ? nz - 1 : 1

	z = (1.0 * (ID / (nx * ny))) / zdiv
	y = 1.0 * ((ID % (nx * ny)) / nx) / ydiv 
	x = 1.0 * (ID % nx) / xdiv

	return x, y, z 
end
function get_hex_node_ids(nx, ny, node0, elem_node_ids)

	#println("nx = $nx, ny = $ny")
	push!(elem_node_ids, node0)
	push!(elem_node_ids, node0 + 1)
	push!(elem_node_ids, node0 + nx + 1)
	push!(elem_node_ids, node0 + nx)
	push!(elem_node_ids, node0 + nx*ny)
	push!(elem_node_ids, node0 + 1 + nx*ny)
	push!(elem_node_ids, node0 + 1 + nx + nx*ny )
	push!(elem_node_ids, node0 + nx + nx*ny)
	
	#println("node_ids = $elem_node_ids")
end
function get_int_coords(ID, nx, ny, nz)

	z = Int64(round((ID/(nx*ny))))
	y = Int64(round((ID%(nx*ny))/nx))
	x = Int64(round((ID%nx)))
	return x, y, z
end

function get_id(nx, ny, nz, x, y, z)

	return x + (nx * (y - 1)) + (nx * ny * (z -1))

end 
