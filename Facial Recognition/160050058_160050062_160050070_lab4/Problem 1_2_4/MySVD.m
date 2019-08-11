function [myU, S, myV] = MySVD(A)
%A = [3,2,2;2,3,-2; 1,2,3; 4,5,6];
s = size(A);
% rows = s(1);
% cols = s(2);

A1 = A*transpose(A);
A2 = transpose(A)*A;

[V1,D1] = eig(A1);
[V2,D2] = eig(A2);
myU = fliplr(V1);
myV = fliplr(V2);
D1new = fliplr(D1);
D2new = fliplr(D2);
%[U,Sig,V] = svd(A);
% [a, b] = size(V1new);
% [c, d] = size(V2new);
% if mod(b, 2) == 0
%     for i = 1:b
%         V1new(:,i) = ((-1)^i).*V1new(:,i);
%     end;
% else
%     for i = 1:b
%         V1new(:,i) = ((-1)^(i-1)).*V1new(:,i);
%     end;
% end;

% if mod(d, 2) == 0
%     for i = 1:d
%         V2new(:,i) = ((-1)^i).*V2new(:,i);
%     end;
% else
%     for i = 1:d
%         V2new(:,i) = ((-1)^(i-1)).*V2new(:,i);
%     end;
% end;
% V1new = zeros(rows,rows);
% for i=1:rows
%     V1new(:,i) = V1(:,rows-i+1);
% end;
% 
% V2new = zeros(cols,cols);
% for i=1:cols
%     V2new(:,i) = V2(:,cols-i+1);
% end;

% if rows > cols
%     eigenValues = sort(eig(A1),'descend');
% else
%     eigenValues = sort(eig(A2),'descend');
% end;
% 
% S = zeros(rows,cols);
% m = min(rows,cols);
% for i=1:m
%     S(i,i) = sqrt(eigenValues(i));
% end;
S = transpose(myU)*A*myV;
disp('Matrix U is -');
disp(myU);
disp('Matrix S is -');
disp(S);
disp('Matrix V is -');
disp(myV);
end



