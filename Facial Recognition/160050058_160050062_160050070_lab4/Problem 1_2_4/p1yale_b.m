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

%Testing images
Images2 = cell(38, 20);
ImageMatrices2 = cell(32, 20);
Xmatrix2 = zeros(32256, 1520);
for i=1:38
    faceFolder2 = strcat('CroppedYale/', srcDirs(i+2).name);
    srcImages2 = dir(fullfile(strcat(faceFolder2,'/*.pgm')));
    for j=1:20
        filename2 = strcat(faceFolder2, '/', srcImages2(j+40).name);
        Images2{i, j}= imread(filename2);
        ImageMatrices2{i, j} = reshape(Images2{i, j}, [32256, 1]);
        Xmatrix2( :, 20*(i-1) + j ) = double(ImageMatrices2{i,j}) - ImageMean;
    end
end

rate = zeros(17, 1);
kList = [1; 2; 3; 5; 10; 15; 20; 30; 50; 60; 65; 75; 100; 200; 300; 500; 1000];
for i=1:17
    k = kList(i);
    [Vmatrix,S,V] = svd(Xmatrix,'econ');
    VmatrixK = Vmatrix(:, 4:k+3);
    alpha = (VmatrixK')*Xmatrix;
    alpha2 = (VmatrixK')*Xmatrix2;
    index = knnsearch(alpha',alpha2','K',1);
    correct = 0;
    for j=1:760
        inAlpha = ceil(index(j)/40);
        inAlpha2 = ceil(j/20);
        if inAlpha==inAlpha2
            correct=correct+1;
        end
    end
    rate(i) = correct/760;
end

pl = plot(kList, rate);
saveas(pl,sprintf('p1yale_b.jpg'));