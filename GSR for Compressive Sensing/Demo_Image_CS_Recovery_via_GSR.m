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

clear
clc
cur = cd;
addpath(genpath(cur));

for ImgNo = 4 % Image Number
    for subrate = 0.3  % CS Sampling Rate
        
        switch ImgNo
            case 1
                filename = 'House256';
            case 2
                filename = 'Barbara256';
            case 3
                filename = 'Leaves256';
            case 4
                filename = 'Vessels96';
        end
        
        % Set Block Size
        block_size = 32;
        
        original_filename = [filename '.tif'];
        original_image = double(imread(original_filename));
        
        [row col] = size(original_image);
        
        % Constructe Measurement Matrix (Gaussian Random)
        N = block_size * block_size;
        M = round(subrate * N);
        randn('seed',0);
        Phi = orth(randn(N, N))';
        Phi = Phi(1:M, :);
        
        x = im2col(original_image, [block_size block_size], 'distinct');
        
        % Get Measurements
        y = Phi * x;
        
        % Obtain Initilization by MH
        disp('Initilization ...');
        [x_MH x_DWT] = MH_BCS_SPL_Decoder(y, Phi, subrate, row, col);
                
        x_org = original_image;
        
        Opts = [];
        Opts.Phi = Phi;
        Opts.block_size = block_size;
        Opts.row = row;
        Opts.col = col;
        
        if ~isfield(Opts,'initial')
            Opts.initial = double(x_MH);
        end
        
        Opts.org = original_image;
        
        if ~isfield(Opts,'IterNum')
            Opts.IterNum = 120;
        end
                
        if ~isfield(Opts,'mu')
            Opts.mu = 2.5e-3;
        end
        
        if ~isfield(Opts,'lambda')
            Opts.lambda = 0.082;
        end
        
        if ~isfield(Opts,'Inloop')
            Opts.Inloop = 200;
        end
        
        fprintf('Initial PSNR = %0.2f\n',csnr(Opts.org,Opts.initial,0,0));
        % Invoke Proposed GSR Alogorithm for Block-based CS Recovery
        disp('Beginning of GSR Algorithm for CS Recovery');

        [reconstructed_image All_PSNR]= BCS_GSR_Decoder_SBI_Iter(y, Opts);
        psnr = PSNR(original_image, reconstructed_image);
        
        % save([filename '_rate_' num2str(subrate) '_results.mat'], 'All_PSNR');
        
        Final_Name_GSR = strcat(filename,'_rate_',num2str(subrate),'_GSR_SBI_Iter','_PSNR_',num2str(csnr(original_image,reconstructed_image,0,0)),'dB.tif');
        imwrite(uint8(reconstructed_image),strcat('GSR_Result\',Final_Name_GSR));
        
        Plot_flag = 0;
        if Plot_flag
            figure;imshow(uint8(reconstructed_image));title(['GSR PSNR = ' num2str(psnr) ' dB']);
            disp(['GSR PSNR = ' num2str(psnr) ' dB']);
            figure; plot(1:Opts.IterNum,All_PSNR, 'LineWidth',2.0),
            title(strcat(filename,' subrate=',num2str(subrate),' Evolution of PSNR (dB)'));
            set(gca,'FontName','Times'),
            set(gca,'FontSize',14),
            xlabel('Iterative Numbers ');
            ylabel('PSNR');
            saveas(gcf,Final_Name_GSR,'png');
        end
        disp('End of GSR');
        
    end
end
