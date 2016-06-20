%
% im_overlay: overlay frame image with tracking (ROI + target)
%
% Input
%   img:        image input
%   xs:         x-pos of tracking
%   ys:         y-pos of tracking
%   target_pos: target frame indicies
%   roi_pos:    ROI frame indicies
% Ouput
%   img:        overlaid image
%
%
% File: im_overlay.m
% Author: Evren KANALICI
% Date: 24/05/2016
% Computer Eng. - Computer Vision, Spring '16
% Yildiz Technical University
%
function img=im_overlay(img,xs,ys,target_pos,roi_pos)

H=size(img,1);
W=size(img,2);
    
centerX=xs(end);
centerY=ys(end);

[cross_x, cross_y] = center_cross(centerX, centerY);

% overlay target
N=size(target_pos,1);
for i=1:N
    row=target_pos(i,1);
    col=target_pos(i,2);
    if (row>=1 && row<=H && col>=1 && col<=W)
        img(row,col,1)=0;
        img(row,col,2)=255;
        img(row,col,3)=0;     
    end
end

% overlay roi
N=size(roi_pos,1);
for i=1:N
    row=roi_pos(i,1);
    col=roi_pos(i,2);
    if (row>=1 && row<=H && col>=1 && col<=W)
        img(row,col,1)=255;
        img(row,col,2)=0;
        img(row,col,3)=0;     
    end
end

% overlay cross
N=size(cross_x,1);
for i=1:N
    row=cross_x(i);
    col=cross_y(i);
    if (row>=1 && row<=H && col>=1 && col<=W)
        img(row,col,1)=0;
        img(row,col,2)=255;
        img(row,col,3)=0;
    end      
end

% overlay track
N=size(xs,2);
for i=1:N
    row=xs(i);
    col=ys(i);
    if (row>=1 && row<=H && col>=1 && col<=W)
        img(row,col,1)=0;
        img(row,col,2)=255;
        img(row,col,3)=0;
    end      
end


return;

function [cross_x, cross_y]=center_cross(centerX,centerY)
    N=4;
    cross_x=[centerX-N:centerX+N ones(1,2*N+1)*centerX]';
    cross_y=[ones(1,2*N+1)*centerY centerY-N:centerY+N]';
    
return;
