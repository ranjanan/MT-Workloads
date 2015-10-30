using CUSPARSE, CUDArt

import Base.*
function *(a::CudaSparseMatrixCSR, b::CudaArray)
	CUSPARSE.csrmv('N', a, b, 'O')
end
