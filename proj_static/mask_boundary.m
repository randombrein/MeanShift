%
% mask_boundary: calculates boundary for a mask
%
% Input
%   mask_idx:       mask indicies (x,y)
% Ouput
%   boun:       boundary indicies for the mask input (x,y)
%
%
% File: mask_boundary.m
% Author: Evren KANALICI
% Date: 24/05/2016
% Computer Eng. - Computer Vision, Spring '16
% Yildiz Technical University
%
function boun=mask_boundary(mask_idx)

% morphological offset
MORPH_OFFSET=2;

% shift delta (considering negative vals. for mask)
delta=max(mask_idx(:))+2*MORPH_OFFSET;  

% add delta to (shift) mask before boundary crop
mask_idx=mask_idx+delta;

maskBW=zeros(2*delta,2*delta);
N=size(mask_idx,1);

for i=1:N
    row=mask_idx(i,1);
    col=mask_idx(i,2);
    maskBW(row,col)=1;  % assign mask
end


SE=strel('disk',MORPH_OFFSET);  % disk-shaped morphological structuring element
eroded=imerode(maskBW,SE);  % erode the image with the strcut element
maskBW=maskBW-eroded;  % get boundary indicies by removing disk

[xs,ys]=find(maskBW);  % boundary indicies

% remove back delta (reshift)
xs=xs-delta;
ys=ys-delta;
boun=[xs,ys];