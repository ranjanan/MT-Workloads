type Box 
	ranges::Array{Int64,1}
end 

type Mesh

	bc_rows_0::Array{Int64,1}
	bc_rows_1::Array{Int64,1}
	global_box::Box
	local_box::Box

end

type CSRMatrix

	has_local_indices::Bool
	rows::Array{Int64,1}
	row_offsets::Array{Int64,1}
	row_offsets_external::Array{Float64,1}
	packed_cols::Array{Int64,1}
	packed_coefs::Array{Float64,1}
	num_cols::Int64

end

type ElemData
	nodes_per_elem::Int64
	elem_node_ids::Array{Int64,1}
	elem_grad_vals::Array{Float64,1}
	elem_node_coords::Array{Float64,1}
	elem_diff_matrix::Array{Float64,1}
	elem_source_vector::Array{Float64,1}
end

type MatrixInitOp

	rows::Array{Int64,1}
	row_offsets::Array{Int64,1}
	row_coords::Array{Int64,1}
	global_nodes_x::Int64
	global_nodes_y::Int64
	global_nodes_z::Int64
	global_nrows::Int64
	dest_rows::Array{Int64,1}
	dest_rowoffsets::Array{Int64,1}
	dest_cols::Array{Int64,1}
	dest_coefs::Array{Float64,1}
	mesh::Mesh
	n::Int64

end
	

type Parameters
    nx::Int64
    ny::Int64
	nz::Int64
	load_imbalance::Int64
end
