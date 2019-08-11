clc; 
clear;
%Training images
Images = cell(32, 6);
ImageMatrices = cell(32, 6);
ImageMean = zeros(10304, 1);
for i=1:32
    for j=1:6
    str = strcat('att_faces/s', num2str(i), '/', num2str(j), '.pgm');
    Images{i, j}= imread(str);
    ImageMatrices{i, j} = reshape(Images{i, j}, [10304, 1]);
    ImageMean = ImageMean + double(ImageMatrices{i, j});
    end
end
ImageMean = ImageMean/192;

Xmatrix = zeros(10304, 192);
DeductedMatrices = cell(32, 6);
for i=1:32
    for j=1:6
        DeductedMatrices{i,j} = double(ImageMatrices{i,j}) - ImageMean;
        Xmatrix( :, 6*(i-1) + j ) = DeductedMatrices{i,j};
    end
end

%Testing images
Images2 = cell(32, 4);
ImageMatrices2 = cell(32, 4);
Xmatrix2 = zeros(10304, 128);
for i=1:32
    for j=1:4
    str = strcat('att_faces/s', num2str(i), '/', num2str(j+6), '.pgm');
    Images2{i, j}= imread(str);
    ImageMatrices2{i, j} = reshape(Images2{i, j}, [10304, 1]);
    Xmatrix2(:, 4*(i-1) + j ) = double(ImageMatrices2{i, j}) - ImageMean;
    end
end

Lmatrix = (Xmatrix')*Xmatrix;
rate = zeros(13, 1);
kList = [1; 2; 3; 5; 10; 15; 20; 30; 50; 75; 100; 150; 170];
for i=1:13
    k = kList(i);
    [Wmatrix,T] = eigs(Lmatrix, k);
    Vmatrix = normc(Xmatrix*Wmatrix);
    alpha = (Vmatrix')*Xmatrix;
    alpha2 = (Vmatrix')*Xmatrix2;
    index = knnsearch(alpha',alpha2','K',1);
    correct = 0;
    for j=1:128
        inAlpha = ceil(index(j)/6);
        inAlpha2 = ceil(j/4);
        if inAlpha==inAlpha2
            correct=correct+1;
        end
    end
    rate(i) = correct/128;
end

pl = plot(kList, rate);
saveas(pl,sprintf('p1eig.jpg'));