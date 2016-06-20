%
% mean_shift: mean-shift localised object tracking function
%
% Input
%   image:      image input
%   center_x:   initial center x-pos of the target patch
%   center_y:   initial center y-pos of the target patch
%   q_u:        target patch distribution 
%   roi:        ROI position mask
%   h:          kernel radius
%   frame_no:   current frame number
% Ouput
%   x_0:        shifted (new) center x-pos of the target patch
%   y_0:        shifted (new) center x-pos of the target patch
%   p_u:        shifted (new) target distribution
%   iters:      total iterations
%
%
% File: mean_shift.m
% Author: Evren KANALICI
% Date: 24/05/2016
% Computer Eng. - Computer Vision, Spring '16
% Yildiz Technical University
%
function [x_0,y_0,p_u,iters]=mean_shift(image,center_x,center_y,...
            q_u,roi,h,frame_no)

MAX_ITER=32;
EPSILON=0.1;

% shifted center pos
x_0=center_x;
y_0=center_y;

% shifted center pos (pre-round)
x_0r=center_x;
y_0r=center_y;

% iteration count
iters=0;

N=size(roi,1);
while 1

    rows=roi(:,1)+x_0;
    cols=roi(:,2)+y_0;
    
    % calculate distribution (p)
    p_u=color_distri(image,x_0,y_0,rows,cols,h);
    
    % calculate weight (w)
    w_i=color_weight(image,rows,cols,q_u,p_u);
    
    % estimate new target center (y1)
    x_i=zeros(2,N);
    x_i(1,:)=roi(:,1)+x_0;
    x_i(2,:)=roi(:,2)+y_0;
    
    if sum(w_i)==0
        break;
    end
    
    % after calculating weights
    % do mean-shift
    % (maximazing bhattarcharya -> minimizing distance)
    y_1=x_i*w_i'/sum(w_i);
    
    shift_x=y_1(1)-x_0r;  
    shift_y=y_1(2)-y_0r;
     
    % update target center (y0=y1)
    x_0r=y_1(1);
    y_0r=y_1(2);

    % round indicies
    x_0=round(x_0r);
    y_0=round(y_0r);
    
    % iteration limit & delta
    iters=iters+1;
    if (iters>=MAX_ITER || sqrt(shift_x^2+shift_y^2)<EPSILON)
        break;
    end
    
end % end-while

fprintf('FRAME-%d:\t%4d iters [MAXITER=%d, DIST_DELTA=%.2f]',...
    frame_no,iters,MAX_ITER,EPSILON);

if iters==MAX_ITER
    fprintf(' MAXITER reached!!!\n');
else
    fprintf('\n');
end


return;