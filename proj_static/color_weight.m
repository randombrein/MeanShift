%
% color_weight: calculates weight for target/candidate patch distributions
%
% Input
%   image:  image input 
%   xs:     x-pos of candidate mask
%   ys:     y-pos of candidate mask
%   q_u:    target patch distribution 
%   p_u:    candidate patch distribution   
% Ouput
%   weight: weights for candidate
%
%
% File: color_weight.m
% Author: Evren KANALICI
% Date: 24/05/2016
% Computer Eng. - Computer Vision, Spring '16
% Yildiz Technical University
%
function weight=color_weight(image,xs,ys,q_u,p_u)

assert(size(xs,1)==size(ys,1));

% quantified RGB-color bins
RQ=16;
GQ=16;
BQ=16;

RB=256/RQ;
GB=256/GQ;
BB=256/BQ;

% image size
imgHeight=size(image,1);                      
imgWidth=size(image,2); 
    
N=size(xs,1);  
%
% calculate weight (1-D)
%
weight=zeros(1,N);
for i=1:N
    if (xs(i)>=1 && xs(i)<=imgHeight && ys(i)>=1 && ys(i)<=imgWidth)
        r=min(RQ,floor(image(xs(i),ys(i),1)/RB)+1);
        g=min(GQ,floor(image(xs(i),ys(i),2)/GB)+1);
        b=min(BQ,floor(image(xs(i),ys(i),3)/BB)+1);
        
        u=GQ*BQ*(r-1)+BQ*(g-1)+b; % delta func. - bin idx (u)
        
        weight(i)=sqrt(q_u(u)/p_u(u));   % weight for bin
    end
end

return;

