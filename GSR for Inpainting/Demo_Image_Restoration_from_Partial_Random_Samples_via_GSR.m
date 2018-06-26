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
% Set image and the ratio of reserving the original data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ratio_Set = [0.2, 0.3, 0.5, 0.8];

for ImgNo = 1
    for ratio_num = 1
        switch ImgNo
            case 1
                OrgName = 'Barbara256rgb.png';
            case 2
                OrgName = 'House256rgb.png';
        end
        ratio = Ratio_Set(ratio_num); % ratio of available data, Options: [0.2, 0.3, 0.5, 0.8]
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Generally, the more the ratio, the less the IterNums.
        if (ratio == 0.2)
            IterNums = 200;
        elseif (ratio == 0.3)
            IterNums = 150;
        elseif (ratio == 0.5)
            IterNums = 100;
        elseif (ratio == 0.8)
            IterNums = 80;
        else
            disp('The ratio does not belong to [0.2, 0.3, 0.5, 0.8]');
            disp('Default IterNums is set to 300');
            IterNums = 300;
        end
        
        x_rgb = imread(OrgName); % Original True Image
        [N,M,dim]=size(x_rgb);
        
        x_yuv = rgb2ycbcr(x_rgb);
        
        x = double(x_yuv(:,:,1)); % Deal with Y Component
        x_org = x;
        x_inpaint_rgb = zeros(size(x_rgb));
        x_inpaint_yuv = zeros(size(x_yuv));
        x_inpaint_yuv(:,:,2) = x_yuv(:,:,2); % Copy U Componet
        x_inpaint_yuv(:,:,3) = x_yuv(:,:,3); % Copy V Componet
        
        
        % Fix random seed
        %rand('seed',0);
        % Generating Random Mask
        
        MaskType = 1; % 1 for random mask; 2 for text mask
        switch MaskType
            case 1
                rand('seed',0);
                O = double(rand(size(x)) > (1-ratio));
            case 2
                O = imread('TextMask256.png');
                O = double(O>128);
        end
        
        
        % Generate Missing Image
        y_missing_rgb = zeros(size(x_rgb));
        y_missing_rgb(:,:,1) = uint8(double(x_rgb(:,:,1)).*O);
        y_missing_rgb(:,:,2) = uint8(double(x_rgb(:,:,2)).*O);
        y_missing_rgb(:,:,3) = uint8(double(x_rgb(:,:,3)).*O);
        
        y= x.* O;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Considering the Case with Gaussian White Noise.
        % When Noise_flag is zero, no noise is added.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Noise_flag = 0;
        if (Noise_flag)
            BSNR = 40;
            Py = var(x(:));
            sigma = sqrt((Py/10^(BSNR/10)));
            % Add noise
            y=y + sigma*randn(N,M);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Opts = [];
        
        if ~isfield(Opts,'IterNums')
            Opts.IterNums = IterNums;
        end
        
        if ~isfield(Opts,'block_size')
            Opts.block_size = 8;
        end
        
        if ~isfield(Opts,'ArrayNo')
            Opts.ArrayNo = 60;
        end
        
        if ~isfield(Opts,'mu')
            Opts.mu = 2.5e-3;
        end
        
        Opts.x_org = x_org;
        
        if ~isfield(Opts,'lambda')
            Opts.lambda = 0.082;
        end        
        
        if ~isfield(Opts,'initial')
            Opts.initial = Interpolation_Initial(y,~O);
        end
        
        
        %Opts.Threshold = Threshold;
        
        fprintf('***************************************************************\n')
        fprintf('***************************************************************\n')
        fprintf('Running GSR ...\n')
        [x_final,MSE] = Inpainting_GSR(y,O,Opts);
        
        PSNR_seq = 10*log10((255.^2)./(MSE));
        
        x_inpaint_yuv(:,:,1) = uint8(x_final);
        x_inpaint_rgb = ycbcr2rgb(uint8(x_inpaint_yuv));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Save Images
        img_inpait_name = strcat(OrgName,'_ratio',num2str(ratio),'_',num2str(csnr(x,x_final,0,0)),'_random_GSR.png');
        img_inpait_plot_name = strcat(OrgName,'_ratio',num2str(ratio),'_',num2str(csnr(x,x_final,0,0)),'_random_plot_GSR.png');
        img_missing_name = strcat(OrgName,'_ratio',num2str(ratio),'_',num2str(csnr(x,y,0,0)),'_random_missing.png');
        imwrite(uint8(x_inpaint_rgb),strcat('GSR_Results\',img_inpait_name));
        imwrite(uint8(y_missing_rgb),strcat('GSR_Results\',img_missing_name));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display Picture and Results
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %figure;imshow(uint8(y_missing_rgb));title(['Missing Image, ratio = ',num2str(ratio),', PSNR = ',num2str(csnr(x,y,0,0))]);
        %figure;imshow(uint8(x_inpaint_rgb));title(['Inpainting Image via GSR, PSNR = ',num2str(csnr(x,x_final,0,0))]);
        %         figure; plot(1:length(MSE), PSNR_seq, 'LineWidth',2.0),
        %         title('Evolution of PSNR (dB)','FontName','Times','FontSize',15),
        %         set(gca,'FontName','Times'),
        %         set(gca,'FontSize',14),
        %         xlabel('Iterative Numbers ');
        %         ylabel('PSNR');
        %         saveas(gcf,img_inpait_plot_name,'png');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        fprintf('GSR Finished...\n')
        fprintf('***************************************************************\n')
        fprintf('***************************************************************\n')
    end
end
