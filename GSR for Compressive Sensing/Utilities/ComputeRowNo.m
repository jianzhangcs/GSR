function row_no = ComputeRowNo(block_no,height)

if mod(block_no,height) == 0
    row_no = height;
else 
    row_no = mod(block_no,height);
end