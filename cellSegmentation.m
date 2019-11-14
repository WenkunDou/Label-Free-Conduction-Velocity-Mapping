%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This programe is used to segment cardiomyocyte from the monolayer 
%   Reference: 
%   Copyright since 2019 by AMNL. All Rights Reserved.
%   E-mail: 
%   2019 Original Version by Qili Zhao
%   2019-10-07 Modified Version by Xingjian Liu, Wenkun Dou
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ center_x, center_y, area ] = cellSegmentation( input_img )
%CELLSEGMENTATION Summary of this function goes here
%   Detailed explanation goes here

% calculate the average grayscale of input image
AveImageArr = [];
AveImage = [];
S = size(input_img);
for j = 1 : S(2)
    AveImageArr = [AveImageArr; uint8(mean(input_img(:,j)))];
end

for k = 1 : S(1)
    AveImage(k,:) = AveImageArr;
end
% calculate the profile of cell
AveImage = uint8(AveImage);
CellImage = AveImage-input_img;
% show cell image
% imshow(CellImage);

% bw the cell image
BinaryCellImage = im2bw(CellImage,0.19);
%imshow(BinaryCellImage);

% label all the cells' profile
L = bwlabel(BinaryCellImage);

% set up the outputs
area = zeros(1,max(L(:)));
center_x = zeros(1,max(L(:)));
center_y = zeros(1,max(L(:)));

for m = 1 : max(L(:))
    area(m) = sum(BinaryCellImage(L==m));
    [y,x] = find(L==m);
    center_x(m) = mean(x(:));
    center_y(m) = mean(y(:));
end


end

