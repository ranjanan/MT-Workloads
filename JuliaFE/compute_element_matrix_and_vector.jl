include("Hex8_Enums.jl")
using Match

function compute_element_matrix_and_vector(elem_data)

	diffusionMatrix_symm(elem_data.elem_node_coords, elem_data.elem_grad_vals, elem_data.elem_diff_matrix)
	sourceVector(elem_data.elem_node_coords, elem_data.elem_grad_vals, elem_data.elem_source_vector)

end

function sourceVector(elemNodeCoords, grad_vals, elem_vec)

	len = numNodesPerElem
	const zero = 0
	fill(elem_vec, len, zero)
	
	gpts = Array(Float64, numGaussPointsPerDim)	
	gwts = Array(Float64, numGaussPointsPerDim)	

	psi = Array(Float64, numNodesPerElem)

	gauss_pts(numGaussPointsPerDim, gpts, gwts)

	Q = 1.0

	pt = Array(Float64, spatialDim)

	gv_offset = 0

	for ig = 1:numGaussPointsPerDim
		pt[1] = gpts[ig]
		wi = gwts[ig]

		for jg = 1:numGaussPointsPerDim
			pt[2] = gpts[jg]
			wj = gwts[jg]

			for kg = 1:numGaussPointsPerDim
				pt[3] = gpts[kg]
				wk = gwts[kg]
				
				shape_fns(pt, psi)
				gv_offset += numNodesPerElem * spatialDim

				detJ = gradients_and_detJ(elemNodeCoords, grad_vals, gv_offset - numNodesPerElem * spatialDim)

				term = Q * detJ * wi * wj * wk 

				for i = 1:numNodesPerElem 
					elem_vec[i] += psi[i] * term
				end
			end
		end
	end
				
end

function gradients_and_detJ(elemNodeCoords, grad_vals, gv_offset)

	const zero = 0

	J11 = zero
	J12 = zero
	J13 = zero

	J21 = zero
	J22 = zero
	J23 = zero

	J31 = zero
	J32 = zero
	J33 = zero

	i_X_spatialDim = 0
	for i = 1:numNodesPerElem
		J11 += grad_vals[gv_offset + i_X_spatialDim + 1] * elemNodeCoords[i_X_spatialDim + 1]
		J12 += grad_vals[gv_offset + i_X_spatialDim + 1] * elemNodeCoords[i_X_spatialDim + 2]
		J13 += grad_vals[gv_offset + i_X_spatialDim + 1] * elemNodeCoords[i_X_spatialDim + 3]

		J21 += grad_vals[gv_offset + i_X_spatialDim + 2] * elemNodeCoords[i_X_spatialDim + 1]
		J22 += grad_vals[gv_offset + i_X_spatialDim + 2] * elemNodeCoords[i_X_spatialDim + 2]
		J23 += grad_vals[gv_offset + i_X_spatialDim + 2] * elemNodeCoords[i_X_spatialDim + 3]

		J31 += grad_vals[gv_offset + i_X_spatialDim + 3] * elemNodeCoords[i_X_spatialDim + 1]
		J32 += grad_vals[gv_offset + i_X_spatialDim + 3] * elemNodeCoords[i_X_spatialDim + 2]
		J33 += grad_vals[gv_offset + i_X_spatialDim + 3] * elemNodeCoords[i_X_spatialDim + 3]

		i_X_spatialDim += spatialDim
	end

	
	term1 = J33*J22 - J32*J23
	term2 = J33*J12 - J32*J13
	term3 = J23*J12 - J22*J13 
	
	detJ = J11*term1 - J21*term2 + J31*term3

	return detJ

end

function shape_fns(x, values_at_nodes)

	values_at_nodes[1] = (1 - x[1]) * (1 - x[2]) * (1 - x[3])
	values_at_nodes[2] = (1 + x[1]) * (1 - x[2]) * (1 - x[3])
	values_at_nodes[3] = (1 + x[1]) * (1 + x[2]) * (1 - x[3])
	values_at_nodes[4] = (1 - x[1]) * (1 + x[2]) * (1 - x[3])
	values_at_nodes[5] = (1 - x[1]) * (1 - x[2]) * (1 + x[3])
	values_at_nodes[6] = (1 + x[1]) * (1 - x[2]) * (1 + x[3])
	values_at_nodes[7] = (1 + x[1]) * (1 + x[2]) * (1 + x[3])
	values_at_nodes[8] = (1 - x[1]) * (1 + x[2]) * (1 + x[3])

end

function diffusionMatrix_symm(elemNodeCoords, grad_vals, elem_mat)

	len = ( numNodesPerElem * (numNodesPerElem + 1) ) /2
	const zero = 0
	fill(elem_mat, len, zero)
	
	gpts = Array(Float64, numGaussPointsPerDim)
	gwts = Array(Float64, numGaussPointsPerDim)

	gauss_pts(numGaussPointsPerDim, gpts, gwts)

	const k = 1.0
	detJ = 0.0

	dpsidx = Array(Float64, numNodesPerElem)
	dpsidy = Array(Float64, numNodesPerElem)
	dpsidz = Array(Float64, numNodesPerElem)

	invJ = Array(Float64, spatialDim * spatialDim)

	pt = Array(Float64, spatialDim)

	volume = zero

	gv_offset = 0
	
	for ig = 1:numGaussPointsPerDim

		for jg = 1:numGaussPointsPerDim

			for kg = 1:numGaussPointsPerDim
				wi_wj_wk = gwts[ig] * gwts [jg] * gwts[kg]

				gv_offset += numNodesPerElem * spatialDim 

				detJ = gradients_and_invJ_and_detJ(elemNodeCoords, grad_vals, gv_offset - numNodesPerElem * spatialDim, invJ, detJ) 
				volume += detJ
				
				k_detJ_wi_wj_wk = k * detJ * wi_wj_wk 
				gv = gv_offset - numNodesPerElem * spatialDim

				for i = 1:numNodesPerElem
					gv0 = grad_vals[gv + 1] 
					gv1 = grad_vals[gv + 2]
					gv2 = grad_vals[gv + 3]

					dpsidx[i] = (gv0 * invJ[1]) + (gv1 * invJ[2]) + (gv2 * invJ[3])
					dpsidy[i] = (gv0 * invJ[4]) + (gv1 * invJ[5]) + (gv2 * invJ[6])
					dpsidz[i] = (gv0 * invJ[7]) + (gv1 * invJ[8]) + (gv2 * invJ[9])

					gv += spatialDim
				end
				
				offset = 1
	
				for m = 1:numNodesPerElem 
					const dpsidx_m = dpsidx[m]
					const dpsidy_m = dpsidy[m]
					const dpsidz_m = dpsidz[m]
					 
					elem_mat[offset] += k_detJ_wi_wj_wk * (dpsidx_m^2 + dpsidy_m^2 + dpsidz_m^2) 
					offset += 1
					
					for n = m+1:numNodesPerElem
						elem_mat[offset] += k_detJ_wi_wj_wk * ((dpsidx_m * dpsidx[n]) + (dpsidy_m * dpsidy[n]) + (dpsidz_m * dpsidz[n]))
					end
				end
			end
		end
	end 
	#println("elem_mat = $(elem_mat[1:end])")					
end

function gradients_and_invJ_and_detJ(elemNodeCoords, grad_vals, gv_offset, invJ, detJ)

	const zero = 0

	J11 = zero
	J12 = zero
	J13 = zero

	J21 = zero
	J22 = zero
	J23 = zero

	J31 = zero
	J32 = zero
	J33 = zero

	i_X_spatialDim = 0
	for i = 1:numNodesPerElem
		J11 += grad_vals[gv_offset + i_X_spatialDim + 1] * elemNodeCoords[i_X_spatialDim + 1]
		J12 += grad_vals[gv_offset + i_X_spatialDim + 1] * elemNodeCoords[i_X_spatialDim + 2]
		J13 += grad_vals[gv_offset + i_X_spatialDim + 1] * elemNodeCoords[i_X_spatialDim + 3]

		J21 += grad_vals[gv_offset + i_X_spatialDim + 2] * elemNodeCoords[i_X_spatialDim + 1]
		J22 += grad_vals[gv_offset + i_X_spatialDim + 2] * elemNodeCoords[i_X_spatialDim + 2]
		J23 += grad_vals[gv_offset + i_X_spatialDim + 2] * elemNodeCoords[i_X_spatialDim + 3]

		J31 += grad_vals[gv_offset + i_X_spatialDim + 3] * elemNodeCoords[i_X_spatialDim + 1]
		J32 += grad_vals[gv_offset + i_X_spatialDim + 3] * elemNodeCoords[i_X_spatialDim + 2]
		J33 += grad_vals[gv_offset + i_X_spatialDim + 3] * elemNodeCoords[i_X_spatialDim + 3]

		i_X_spatialDim += spatialDim
	end

	term1 = J33*J22 - J32*J23
	term2 = J33*J12 - J32*J13
	term3 = J23*J12 - J22*J13 
	
	detJ = J11*term1 - J21*term2 + J31*term3
	
	inv_detJ = 1.0/detJ

	invJ[1] =  term1 * inv_detJ	 
	invJ[2] = -term2 * inv_detJ	 
	invJ[3] =  term3 * inv_detJ	 

	invJ[4] = -(J33*J21 - J31*J23)*inv_detJ
  	invJ[5] =  (J33*J11 - J31*J13)*inv_detJ
  	invJ[6] = -(J23*J11 - J21*J13)*inv_detJ

  	invJ[7] =  (J32*J21 - J31*J22)*inv_detJ
  	invJ[8] = -(J32*J11 - J31*J12)*inv_detJ
  	invJ[9] =  (J22*J11 - J21*J12)*inv_detJ

	return detJ

end
function gauss_pts(N, pts, wts)

	const x2 = 1 / sqrt(3)
	const x2 = sqrt(3) / sqrt(5)
	const w1 = 5 / 9
	const w2 = 8 / 9

	@match N begin 
		1 => begin
			pts[1] = 0.0
			wts[1] = 0.0
		end
		2 => begin
			pts[1] = -x2
			pts[2] = x2
			wts[1] = 1.0
			wts[2] = 1.0
		end
	end
			   
end
function fill(mat, len, val)

	if (size(mat)[1] == 0)
		for i = 1:len 
			push!(mat, val)
		end
	else 
		for i = 1:len
			mat[Int64(i)] = val
		end
	end

end
