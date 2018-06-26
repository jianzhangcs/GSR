%   These MATLAB programs implement the color image restroation from partial random samples
%   algorithm using group-based sparse representation (GSR) model as described in paper:
%   
%     Title:  Group-based Sparse Representation for Image Restoration
%     Author: Jian Zhang, Debin Zhao, Wen Gao
%   
% 
% -------------------------------------------------------------------------------------------------------
% The software implemented by MatLab 7.10.0(2010a) are included in this package.
%
% ------------------------------------------------------------------
% Requirements
% ------------------------------------------------------------------
% *) Matlab 7.10.0(2010a) or later with installed:
% ------------------------------------------------------------------
% Version 3.0
% Author: Jian Zhang
% Email:  jianzhang.tech@gmail.com
% Last modified by J. Zhang, April 2014



%close all;
clear;
clc;
cur = cd;
addpath(genpath(cur));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameter Set
% Set image and the type of blur operator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ImgNo = 1
    for Blur_type = 3 % six cases [1 2 3 4 5 6]
        
        switch ImgNo
            case 1
                ImgName = 'House256.png';
            case 2
                ImgName = 'Cameraman256.tif';
            case 3
                ImgName = 'barbara.png';
            case 4
                ImgName = 'Lena512.png';
        end
        
        x_org = double(imread(ImgName));
        
        switch Blur_type
            case 1
                sigma=sqrt(2);
                for x1=-7:7; for x2=-7:7; v(x1+8,x2+8)=1/(x1^2+x2^2+1); end, end;
                v=v./sum(v(:));
            case 2
                sigma=sqrt(8);
                s1=0; for a1=-7:7; s1=s1+1; s2=0; for a2=-7:7; s2=s2+1; v(s1,s2)=1/(a1^2+a2^2+1); end, end;
                v=v./sum(v(:));
            case 3
                BSNR=40;
                sigma=-1; % if "sigma=-1", then the value of sigma depends on the BSNR
                v=ones(9); v=v./sum(v(:));
            case 4
                sigma=7;
                v=[1 4 6 4 1]'*[1 4 6 4 1]; v=v./sum(v(:));
            case 5
                sigma=2;
                v=fspecial('gaussian', 25, 1.6);
            case 6
                sigma=8;
                v=fspecial('gaussian', 25, .4);
        end
        
        % Create Blurring Operator
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [Xv, Xh]  = size(x_org);
        [ghy,ghx] = size(v);
        big_v  = zeros(Xv,Xh); big_v(1:ghy,1:ghx)=v;
        big_v=circshift(big_v,-round([(ghy-1)/2 (ghx-1)/2])); % pad PSF with zeros to whole image domain, and center it
        h = big_v;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        y_blur = imfilter(x_org, v, 'circular');
        
        if sigma == -1
            Psig  = norm(y_blur,'fro')^2/(Xv*Xh);
            sigma = norm(y_blur-mean(mean(y_blur)),'fro')/sqrt(Xv*Xh*10^(BSNR/10));
        end
        
        % Fix random seed
        randn('seed',0);
        % Observed Blurred Image
        y = y_blur + sigma*randn(Xv,Xh);
        
        Blurred_Name = strcat(ImgName,'_Blurred_','Type_',num2str(Blur_type),'_PSNR_',num2str(csnr(x_org,y,0,0)),'dB.tif');
        imwrite(uint8(y),strcat('GSR_Results\',Blurred_Name));
        
        Opts = [];
             
        switch Blur_type
            case 1
                % Optimal Parameter
                Opts.mu = 2.5e-3*5;
                Opts.lambda = 0.640;
            case 2
                % Optimal Parameter
                Opts.mu = 2.5e-3*30;
                Opts.lambda = 1.383;
            case 3
                % Optimal Parameter
                Opts.mu  = 2.5e-3;
                Opts.lambda = 0.082;
            case 4
                % Optimal Parameter
                Opts.mu  = 2.5e-3*150;
                Opts.lambda = 12.293;
            case 5
                % Optimal Parameter
                Opts.mu  = 2.5e-3*10;
                Opts.lambda = 0.819;
            case 6
                % Optimal Parameter
                Opts.mu  = 2.5e-3*250;
                Opts.lambda = 46.099;
        end  
        
        Opts.org = x_org;
        
        if ~isfield(Opts,'max_iterations')
            Opts.IterNums = 80;
        end
        
        if ~isfield(Opts,'initial')
            Opts.initial = y;
        end
        
        if ~isfield(Opts,'block_size')
            Opts.block_size = 8;
        end
        
        
        fprintf('***************************************************************\n')
        fprintf('***************************************************************\n')
        fprintf('Running GSR Algorithm for Image Deblurring ...\n')
        [x_final,MSE] = Deblurring_GSR(y,h,Opts);
        
        PSNR_seq = 10*log10((255.^2)./(MSE));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display Picture and Results
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(99);imshow(uint8(y));title(['Degraded Image, PSNR = ',num2str(csnr(x_org,y,0,0))]);
        figure(100);imshow(uint8(x_final));title(['Deblurred Image via GSR, PSNR = ',num2str(csnr(x_org,x_final,0,0))]);
        figure; plot(1:length(MSE), PSNR_seq, 'LineWidth',2.0),
        title('Evolution of PSNR (dB)','FontName','Times','FontSize',15),
        set(gca,'FontName','Times'),
        set(gca,'FontSize',14),
        xlabel('Iterative Numbers ');
        ylabel('PSNR');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Compute ISNR
        ISNR = csnr(x_org,x_final,0,0) - csnr(x_org,y,0,0);
        
        Deblurred_Name = strcat(ImgName,'_GSR','_Type_',num2str(Blur_type),'_ISNR_',num2str(ISNR),'dB.tif');
        imwrite(uint8(x_final),strcat('GSR_Results\',Deblurred_Name));
        pause(2);
        fprintf('GSR Finished...\n')
        fprintf('***************************************************************\n')
        fprintf('***************************************************************\n')
        
        
    end
end


