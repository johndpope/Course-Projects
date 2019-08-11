clc; 
clear;
%Training images
Images = cell(38, 40);
ImageMatrices = cell(38, 40);
ImageMean = zeros(32256, 1);

srcDirs = dir(fullfile('CroppedYale'));
for i=1:38
    faceFolder = strcat('CroppedYale/', srcDirs(i+2).name);
    srcImages = dir(fullfile(strcat(faceFolder,'/*.pgm')));
    for j=1:40
        filename = strcat(faceFolder, '/', srcImages(j).name);
        Images{i, j}= imread(filename);
        ImageMatrices{i, j} = reshape(Images{i, j}, [32256, 1]);
        ImageMean = ImageMean + double(ImageMatrices{i, j});
    end
end
ImageMean = ImageMean/1520;

Xmatrix = zeros(32256, 1520);
DeductedMatrices = cell(38, 40);
for i=1:38
    for j=1:40
        DeductedMatrices{i,j} = double(ImageMatrices{i,j}) - ImageMean;
        Xmatrix( :, 40*(i-1) + j ) = DeductedMatrices{i,j};
    end
end

chosenFace =imread('CroppedYale/yaleB01/yaleB01_P00A-010E+00.pgm');
ImageMatrix = reshape(chosenFace, [32256, 1]);
chosenMatrix = double(ImageMatrix) - ImageMean;

rate = zeros(9, 1);
FinalImage = cell(9, 1);
kList = [2; 10; 20; 50; 75; 100; 125; 150; 175];
for i=1:9
    k = kList(i);
    [Vmatrix,S,V] = svd(Xmatrix,'econ');
    VmatrixK = Vmatrix(:, 1:k);
    alpha2 = (VmatrixK')*chosenMatrix;
    Final = ImageMean+VmatrixK*alpha2;
    FinalImage{i} = mat2gray(reshape(Final, [192, 168]));
end

Recon1 = cat(2, FinalImage{1}, FinalImage{2}, FinalImage{3});
Recon2 = cat(2, FinalImage{4}, FinalImage{5}, FinalImage{6});
Recon3 = cat(2, FinalImage{7}, FinalImage{8}, FinalImage{9});
FinalRecon = cat(1, Recon1, Recon2, Recon3);
imwrite(FinalRecon, 'p2_recon.png');

top25 = cell(25, 1);
for i=1:25
    EigMat = Vmatrix(:, i);
    top25{i} = mat2gray(reshape(EigMat, [192, 168]));
end

top1 = cat(2, top25{1}, top25{2}, top25{3}, top25{4}, top25{5});
top2 = cat(2, top25{6}, top25{7}, top25{8}, top25{9}, top25{10});
top3 = cat(2, top25{11}, top25{12}, top25{13}, top25{14}, top25{15});
top4 = cat(2, top25{16}, top25{17}, top25{18}, top25{19}, top25{20});
top5 = cat(2, top25{21}, top25{22}, top25{23}, top25{24}, top25{25});
FinalTop = cat(1, top1, top2, top3, top4, top5);
imwrite(FinalTop, 'p2_top25.png');