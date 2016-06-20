%
% patch_mask: calculates circular patch & ROI masks
%
% Input
%   cx:         center x-pos of patch
%   cy:         center y-pos of patch
%   h:          kernel radius
%   roi_mult:   ROI multiplier w.r.t kernel radius
%   imageSizeX: image height
%   imageSizeY: image width
% Ouput
%   rx:         circular patch mask x-pos indicies
%   ry:         circular patch mask y-pos indicies
%   roix:       ROI mask x-pos indicies
%   roiy:       ROI mask y-pos indicies
%
% File: target_mask.m
% Author: Evren KANALICI
% Date: 24/05/2016
% Computer Eng. - Computer Vision, Spring '16
% Yildiz Technical University
%
function [rx,ry,roix,roiy]=patch_mask(cx,cy,h,roi_mult,imageSizeX,imageSizeY)

    [rr,cc]=meshgrid(1:imageSizeY, 1:imageSizeX);
    
    % circular target mask
    circleMask=(cc-cx).^2 + (rr-cy).^2 <= h.^2;
    [rx,ry]=find(circleMask);
    
    % target ROI mask
    roiMask=abs(cc-cx) <= h*roi_mult & abs(rr-cy) <= h*roi_mult;
    [roix,roiy]=find(roiMask);
    
return;