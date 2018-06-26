function A=blow(B)

[n,m,c]=size(B);
n=2*n;m=2*m;
A=zeros(n,m,c);

A(1:2:n,1:2:m,:)=B;
A(1:2:n,2:2:m,:)=B;
A(2:2:n,1:2:m,:)=B;
A(2:2:n,2:2:m,:)=B;

return;
