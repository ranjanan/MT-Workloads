function sum_into_global_linear_system(elem_data, A, b)

	sum_in_symm_elem_matrix(elem_data.nodes_per_elem, elem_data.elem_node_ids, elem_data.elem_diff_matrix, A)
	sum_into_vector(elem_data.nodes_per_elem, elem_data.elem_node_ids, elem_data.elem_source_vector, b)

end

function sum_into_vector(num_indices, indices, coefs, vec)

	first = 1
	last = size(vec)[1]
	
	for i = 1:num_indices
		if indices[i] < first || indices[i] > last
			continue
		end
		idx = indices[i] #- first
		vec[idx] += coefs[i]
	end 
		
end

function sum_in_symm_elem_matrix(num, indices, coefs, mat)
	
	row_offset = 0
	flag = false

	#println("indices = $indices")	
	for i = 1:num
		row = indices[i]
		if row<0
		println("row = $(indices[i])")
		end	
	
		row_len = num - i
		row_offset += row_len

		mat_row_len = 0
		offset, mat_row_len = get_row_pointers(row, mat)
		
		sum_into_row(mat_row_len, mat.packed_cols, mat.packed_coefs, offset, row_len, indices, i - 1, coefs, row_offset - row_len)
	
		offset_i = i
		for j = 1:i - 1 #bosingwa
			coef = Array(Float64,1)
			coef[1] = coefs[offset_i]
			sum_into_row(mat_row_len, mat.packed_cols, mat.packed_coefs, offset, 1, indices, j, coef, 0)
			offset_i += num - (j + 1)
		end
	end

end

function sum_into_row(row_len, row_indices, row_coefs, offset, num_inputs, input_indices, it, input_coefs, row_offset)

	for i = 1:num_inputs
		#println("$it + $i = $(it + i)")
		loc = lower_bound(row_indices, offset, row_len, input_indices[it + i])
		if loc - offset < row_len && row_indices[loc] == input_indices[it + i]
			#println("left = $loc, right = $(row_offset + i), $(row_coefs[loc]) ($(typeof(row_coefs[loc]))) += $(input_coefs[row_offset + i])")
			row_coefs[loc] += input_coefs[row_offset + i]
		end
	end

end

function lower_bound(row_indices, offset, row_len, val)

	#println("offset = $offset, row_len = $row_len, val = $val, row_indices = $(row_indices[1:100])")
	for i = offset + 1:offset + row_len 
		if row_indices[i] >= val
			return i
		end
	end

end
function get_row_pointers(row, mat)

	local_row = -1
	if size(mat.rows)[1] >= 1
		#println("row = $row, mat_row = $(mat.rows[1:100])")
		idx = row - mat.rows[1] + 1
		if idx<0
		println("idx = $idx")
		end
		#if (idx>0) 
			if (idx <= size(mat.rows)[1] && mat.rows[idx] == row )
				local_row = idx
			end
		#end
	end

	if local_row == -1
		local_row = lower_bound(mat.rows, 1, size(mat.rows)[1], row)
	end

	#println("local_row = $local_row")
	#println("row_offsets = $(mat.row_offsets[1:100])")
	offset = mat.row_offsets[local_row]
	row_len = mat.row_offsets[local_row + 1] - offset
	
	return offset, row_len 
end
