

load LSB.mat;

% load LSBrandom.mat;

count = imhist(data1);

[row,col] = size(count);

h = zeros(128,1);

k = 0;
r = 0;
for i = 1 : 128
    h(i,1) = (count(2*i-1,1) + count(2*i,1))/2;
    if h(i,1) == 0
        continue;
    end
    r = r + (h(i,1) - count(2*i-1,1))*(h(i,1) - count(2*i-1,1))/h(i,1) ;
    k = k + 1;
end



p = 1 - chi2cdf(r,k-1);