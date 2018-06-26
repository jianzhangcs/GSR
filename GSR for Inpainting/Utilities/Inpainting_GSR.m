function [x_final,MSE] = Inpainting_GSR(y,A,Opts)

mu = Opts.mu;
initial = Opts.initial;
IterNums = Opts.IterNums;
true = Opts.x_org;

mask = A;
A = @(x) mask.*x;
AT = @(x) mask.*x;

ATy = AT(y);
x = initial;
c = zeros(size(y));
w = zeros(size(y));
muinv = 1/mu;
invAAT = 1./(mu+mask);

MSE = zeros(1,IterNums+1);
MSE(1) = sum(sum((x-true).^2))/numel(x);

fprintf('Initial PSNR = %f\n',csnr(x,true,0,0));


for Outloop = 1:IterNums
    
    w = GSR_Solver_Inpainting(x-c, Opts);
    
    r = ATy +mu*(w+c);
    x = muinv*(r - AT(invAAT.*A(r)));
    
    c = c + (w - x);
    
    x_resid = x - true;
    MSE(Outloop+1) =  (x_resid(:)'*x_resid(:))/numel(x);
    fprintf('iter number = %d, PSNR = %f\n',Outloop,csnr(x,true,0,0));
    
end

x_final = x;

fprintf('Final PSNR = %f\n',csnr(x_final,true,0,0));

end

