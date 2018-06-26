function [ImgRec] = GSR_Solver_Deblur(ImgInput, Opts)

if ~isfield(Opts,'PatchSize')
    Opts.PatchSize = 8;
end

if ~isfield(Opts,'SlidingDis')
    Opts.SlidingDis = 4;
    Opts.Factor = 240;
end

if ~isfield(Opts,'ArrayNo')
    Opts.ArrayNo = 60;
end

if ~isfield(Opts,'SearchWin')
    Opts.SearchWin = 20;
end


[Hight Width]   =   size(ImgInput);
SearchWin = Opts.SearchWin;
PatchSize    =    Opts.PatchSize;
PatchSize2    =   PatchSize*PatchSize;
ArrayNo   =   Opts.ArrayNo;
SlidingDis = Opts.SlidingDis;

tau =  Opts.lambda*Opts.Factor/Opts.mu;
Threshold = sqrt(2*tau);

N     =  Hight-PatchSize+1;
M     =  Width-PatchSize+1;
L     =  N*M;

Row     =  [1:SlidingDis:N];
Row     =  [Row Row(end)+1:N];
Col     =  [1:SlidingDis:M];
Col    =  [Col Col(end)+1:M];

PatchSet     =  zeros(PatchSize2, L, 'single');

Count     =  0;
for i  = 1:PatchSize
    for j  = 1:PatchSize
        Count    =  Count+1;
        Patch  =  ImgInput(i:Hight-PatchSize+i,j:Width-PatchSize+j);
        Patch  =  Patch(:);
        PatchSet(Count,:) =  Patch';
    end
end

PatchSetT  =   PatchSet';

I        =   (1:L);
I        =   reshape(I, N, M);
NN       =   length(Row);
MM       =   length(Col);

ImgTemp     =  zeros(Hight, Width);
ImgWeight   =  zeros(Hight, Width);
IndcMatrix  =  zeros(NN, MM, ArrayNo);
PatchArray  =  zeros(PatchSize, PatchSize, ArrayNo);

%tic;

for  i  =  1 : NN
    for  j  =  1 : MM
        
        CurRow      =   Row(i);
        CurCol      =   Col(j);
        Off      =   (CurCol-1)*N + CurRow;
        
        CurPatchIndx  =  PatchSearch(PatchSetT, CurRow, CurCol, Off, ArrayNo, SearchWin, I);
		CurPatchIndx(1) = Off;
        %IndcMatrix(i,j,:) = CurPatchIndx;
        
        CurArray = PatchSet(:, CurPatchIndx);
        
        [SG_S SG_V SG_D] = svd(CurArray);
        
        SG_Z = SG_V.*(abs(SG_V)>Threshold);
        non_zero = length(find(SG_Z>0));
        CurArray = SG_S*SG_Z*SG_D';
        
        for k = 1:ArrayNo
            PatchArray(:,:,k) = reshape(CurArray(:,k),PatchSize,PatchSize);
        end
        
        for k = 1:length(CurPatchIndx)
            RowIndx  =  ComputeRowNo((CurPatchIndx(k)), N);
            ColIndx  =  ComputeColNo((CurPatchIndx(k)), N);
            ImgTemp(RowIndx:RowIndx+PatchSize-1, ColIndx:ColIndx+PatchSize-1)    =   ImgTemp(RowIndx:RowIndx+PatchSize-1, ColIndx:ColIndx+PatchSize-1) + PatchArray(:,:,k)';
            ImgWeight(RowIndx:RowIndx+PatchSize-1, ColIndx:ColIndx+PatchSize-1)  =   ImgWeight(RowIndx:RowIndx+PatchSize-1, ColIndx:ColIndx+PatchSize-1) + 1;
        end
        
    end
end

%save ('IndcMatrix.mat', 'IndcMatrix');
ImgRec = ImgTemp./(ImgWeight+eps);

%toc;

return;



