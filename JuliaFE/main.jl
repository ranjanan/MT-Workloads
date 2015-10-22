include("driver.jl")

function main()
	params = Parameters(100, 100, 100, 0)
	global_box = Box([0, 100, 0, 100, 0, 100])
	local_boxes = global_box #Meant to be a vector but only one process assumedi
	my_box = local_boxes
	driver(global_box, my_box, params)
end
