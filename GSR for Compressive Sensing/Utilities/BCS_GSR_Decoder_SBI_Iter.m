
function [reconstructed_image All_PSNR] = BCS_GSR_Decoder_SBI_Iter(y, Opts)

row = Opts.row;
col = Opts.col;
Phi = Opts.Phi;
x_org = Opts.org;
IterNum = Opts.IterNum;
x_initial = Opts.initial;
block_size = Opts.block_size;
Inloop = Opts.Inloop;
mu = Opts.mu;

x = im2col(x_initial, [block_size block_size], 'distinct');

u = zeros(size(x));
b = zeros(size(x));

All_PSNR = zeros(1,IterNum);


ATA = Phi'*Phi;
ATy = Phi'*y;
IM = eye(size(ATA));

for i = 1:IterNum
    
    x_hat = x;
             
    r = col2im(x_hat - b, [block_size block_size],[row col], 'distinct');  
    
    x_bar = GSR_Solver_CS(r, Opts);
    
    x_bar = im2col(x_bar, [block_size block_size], 'distinct');
    
    u = x_bar;
    
    for kk = 1:Inloop
        
        d = ATA*x_hat - ATy + mu*(x_hat - u - b);
        dTd = d'*d;
        G = d'*(ATA + mu*IM)*d;
        Step_Matrix = abs(dTd./G); 
        Step_length = diag(diag(Step_Matrix));
        x = x_hat - d*Step_length;
        x_hat = x;  
        
    end
    
    b = b - (x - u);
   
    x_img = col2im(x, [block_size block_size],[row col], 'distinct');
    
    Cur_PSNR = csnr(x_img,x_org,0,0);
    All_PSNR(i) = Cur_PSNR;
    fprintf('IterNum = %d, PSNR = %0.2f\n',i,Cur_PSNR);
    
end

reconstructed_image = col2im(x, [block_size block_size],[row col], 'distict');

