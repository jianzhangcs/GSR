function  INDX  =  PatchSearch(X, Row, Col, Off, Nv, S, I)

[N M]   =   size(I);
Dim2      =   size(X,2);

rmin    =   max( Row-S, 1 );
rmax    =   min( Row+S, N );
cmin    =   max( Col-S, 1 );
cmax    =   min( Col+S, M );
         
idx     =   I(rmin:rmax, cmin:cmax);
idx     =   idx(:);
B       =   X(idx, :);        
v       =   X(Off, :);
                
dis     =   (B(:,1) - v(1)).^2;

for k = 2:Dim2
    dis   =  dis + (B(:,k) - v(k)).^2;
end
dis   =  dis./Dim2;

[val, ind]   =  sort(dis);

INDX        =  idx( ind(1:Nv) );

