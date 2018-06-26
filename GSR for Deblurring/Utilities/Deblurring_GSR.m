function [x_final,MSE] = Deblurring_GSR(y,A,Opts)

mu = Opts.mu;
x_org = Opts.org;
IterNums = Opts.IterNums;
initial = Opts.initial;

h = A;
H_FFT = fft2(h);
HC_FFT = conj(H_FFT);
A = @(x) real(ifft2(H_FFT.*fft2(x)));
AT = @(x) real(ifft2(HC_FFT.*fft2(x)));

ATy = AT(y);

x = initial;

c = zeros(size(y));
w = zeros(size(y));

muinv = 1/mu;

filter_FFT = HC_FFT./(abs(H_FFT).^2 + mu).*H_FFT;

MSE = zeros(1,IterNums+1);

MSE(1) = sum(sum((x-x_org).^2))/numel(x);


fprintf('Initial PSNR = %f\n',csnr(x,x_org,0,0));


for Outloop = 1:IterNums
    
    w = GSR_Solver_Deblur(x-c,Opts);
    
    r = ATy + mu*(w+c);
    x = muinv*( r - real(ifft2(filter_FFT.*fft2(r))) );
    
    c = c + (w - x);
    
    x_resid = x - x_org;
    MSE(Outloop+1) =  (x_resid(:)'*x_resid(:))/numel(x);
    fprintf('iter number = %d, PSNR = %f\n',Outloop,csnr(x,x_org,0,0));
      
end

x_final = x;

fprintf('Final PSNR = %f\n',csnr(x_final,x_org,0,0));

end

