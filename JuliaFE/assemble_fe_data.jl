using Match
include("perform_element_loop.jl")

function assemble_fe_data(mesh, A, b, params)
	
	local_elem_box = mesh.local_box
	perform_element_loop(mesh, local_elem_box, A, b, params)

end
