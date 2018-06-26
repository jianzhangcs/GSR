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
for ImgNo = 2
    for Blur_type = 7 % six cases [1 2 3 4 5 6]
        
        switch ImgNo
            case 1
                ImgName = 'house.tif';
            case 2
                ImgName = 'barbara.tif';
            case 3
                ImgName = 'boats.tif';
            case 4
                ImgName = 'cameraman.tif';
            case 5
                ImgName = 'lena256.tif';
            case 6
                ImgName = 'peppers.tif';
        end
        
        x_org = double(imread(ImgName));
        
        switch Blur_type
            case 7
                sigma=sqrt(2);
                v=ones(9); v=v./sum(v(:));
            case 8
                sigma=sqrt(2);
                v=fspecial('gaussian', 25, 1.6);
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
        
        
        % Fix random seed
        randn('seed',0);
        % Observed Blurred Image
        y = y_blur + sigma*randn(Xv,Xh);
        
        
        Blurred_Name = strcat(ImgName,'_Blurred_','Type_',num2str(Blur_type),'_PSNR_',num2str(csnr(x_org,y,0,0)),'dB.tif');
        imwrite(uint8(y),strcat('GSR_Results\',Blurred_Name));
        
        Opts = [];
        
        switch Blur_type
            case 7
                % Optimal Parameter
                Opts.mu = 2.5e-3*3;
                Opts.lambda = 0.5532;
            case 8
                % Optimal Parameter
                Opts.mu = 2.5e-3*5;
                Opts.lambda = 0.4098;
        end
        
        Opts.org = x_org;
        
        if ~isfield(Opts,'max_iterations')
            Opts.IterNums = 100;
        end
        
        if ~isfield(Opts,'initial')
            Opts.initial = y;
        end
        
        if ~isfield(Opts,'block_size')
            Opts.block_size = 8;
        end
        
        
        fprintf('***************************************************************\n')
        fprintf('***************************************************************\n')
        fprintf('Running GSR Algorithm for Gray Image Deblurring ...\n')
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
        
        % Compute PSNR
        PSNR = csnr(x_org,x_final,0,0);
        
        Deblurred_Name = strcat(ImgName,'_GSR','_Type_',num2str(Blur_type),'_PSNR_',num2str(PSNR),'dB','.png');
        imwrite(uint8(x_final),strcat('GSR_Results\',Deblurred_Name));
        imwrite(uint8(x_final),strcat('GSR_Results\',Deblurred_Name));
        pause(1);
        fprintf('GSR Finished...\n')
        fprintf('***************************************************************\n')
        fprintf('***************************************************************\n')
        
        
    end
end


