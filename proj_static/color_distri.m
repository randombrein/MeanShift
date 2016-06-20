%
% color_distri: calculates quantized color distribution of the patch (PDD)
%
% Input
%   image:  image input
%   cx:     center x-pos of the patch
%   cy:     center y-pos of the patch
%   xs:     x-pos of patch mask
%   ys:     y-pos of patch mask
%   h:      kernel radius
% Ouput
%   distri: quantized color distribution
%
%
% File: wrapper.m
% Author: Evren KANALICI
% Date: 24/05/2016
% Computer Eng. - Computer Vision, Spring '16
% Yildiz Technical University
%
function distri=color_distri(image,cx,cy,xs,ys,h)

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

% calculate model kernel (Epanechnikov)
kernel=(xs-cx).^2+(ys-cy).^2;
kernel=sqrt(kernel);
kernel(kernel>h)=0;
kernel=h-kernel; 
         
N=size(xs,1);  

%
% calculate histogram (3-D)
%
histo=zeros(RQ,GQ,BQ); 
for i=1:N
    if (xs(i)>=1 && xs(i)<=imgHeight && ys(i)>=1 && ys(i)<=imgWidth)
        r=min(RQ,floor(image(xs(i),ys(i),1)/RB)+1);
        g=min(GQ,floor(image(xs(i),ys(i),2)/GB)+1);
        b=min(BQ,floor(image(xs(i),ys(i),3)/BB)+1);
        histo(r,g,b)=histo(r,g,b)+kernel(i);  % weighted histo. value
    end
end


%
% calculate distribution (1-D)
%
distri=zeros(1,RQ*GQ*BQ);
for r=1:RQ
    for g=1:GQ
        for b=1:BQ
            idx=GQ*BQ*(r-1)+BQ*(g-1)+b;            
            distri(idx)=histo(r,g,b);
        end
    end
end

distri=distri/sum(distri);  % normalize distribution (PDD)
distri(isnan(distri))=0;

return;

