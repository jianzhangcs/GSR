function u=projk(g,lambda,niter)

tau=0.25;

[uy,ux]=size(g);

pn=zeros(uy,ux,2);

for i=1:niter
    qn = Q(Qstar(pn)-g/lambda);
    pn=(pn + tau*qn)./(1 + tau*abs(qn));
end

u = g - lambda*Qstar(pn);

function  y = Q(x)

[m,n] = size(x);

y = zeros(m,n,2);

y(:,:,1) = diffh1(x);
y(:,:,2) = diffv1(x);


function y = Qstar(x)

[m,n,p] = size(x);

y = diffh2(x(:,:,1)) + diffv2(x(:,:,2));

function y=diffh1(x)
h=[0 1 -1];
y=conv2c(x,h);

function y=diffv1(x)
h=[0 1 -1]';
y=conv2c(x,h);

function y=diffh2(x)
h=[1 -1 0];
y=conv2c(x,h);

function y=diffv2(x)
h=[1 -1 0]';
y=conv2c(x,h);
