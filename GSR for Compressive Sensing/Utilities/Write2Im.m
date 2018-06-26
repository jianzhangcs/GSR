function [d_im  cnt_im] =  Write2Im( Block, b, d_im0, cnt_im0, row, col, height, width )

d_im    =  d_im0;
cnt_im  =  cnt_im0;

for  m  = -b:b
    for  k  = -b:b
   
        row1  =  row + m;
        col1  =  col + k;
        
        if ( row1>0 && row1<=height ) && ( col1>0 && col1<=width )
            
            d_im( row1, col1 )    =  d_im( row1, col1 ) + Block( m+b+1, k+b+1 );
            cnt_im( row1, col1 )  =  cnt_im( row1, col1 ) + 1;

        end
        
    end
end
