%
% Mean-shift object tracking implementation
%   1 - Read video & values
%   2 - Select Target
%   3 - Run tracking algo.
%
%
% File: wrapper.m
% Author: Evren KANALICI
% Date: 24/05/2016
% Computer Eng. - Computer Vision, Spring '16
% Yildiz Technical University
%

%% 1 - Read video & values
%======================================================================
clc;
clear all;

FILEPATH='assets/ball.m4v';
SELECT_POLY=false;

% Create a VideoReader object to read data from the sample file. 
% Then, determine the width and height of the video.
vid = VideoReader(FILEPATH);
vidWidth = vid.Width;
vidHeight = vid.Height;

% Create a movie structure array, mov.
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);

% Read one frame at a time until the end of the video is reached.
k = 1;
while hasFrame(vid)
    mov(k).cdata = readFrame(vid);
    k = k+1;
end
numberofframes=size(mov,2);
frame0=mov(1).cdata;

% Size a figure based on the width and height of the video. 
% Then, play back the movie once at the video frame rate.
hf = figure;
set(hf,'position',[150 150 vidWidth vidHeight]);

movie(hf,mov,1,vid.FrameRate);


%% 2 - Select Target
%======================================================================

% Relative ROI/rad multiplier
ROI_MULT=5;

% image size
imageSizeX=size(frame0,1);
imageSizeY=size(frame0,2);
            
% select polygol manually
if SELECT_POLY
    figure(1),imMask=roipoly(frame0); % get image mask
    assert(size(imMask,1) > 0 && size(imMask,2) > 0, 'Select a Target in the dialog!');
    [rx,ry]=find(imMask);  % mask indicies                        
    m0=floor(mean([rx,ry]))';  % mask center 

    % mask center position
    x_0=m0(1);
    y_0=m0(2);  

    % calculate kernal-radius
    rads=(rx-x_0).^2+(ry-y_0).^2;
    rads=sqrt(rads);
    h=sum(rads)/size(rads,1);
    
    fprintf('x_0=%d,y_0=%d,h=%d\n',x_0,y_0,h);
    
% static values
elseif strcmp(FILEPATH,'assets/ball.m4v')
    x_0=105;
    y_0=16;
    h=7.801963e+00;
elseif strcmp(FILEPATH,'assets/ball2.m4v')
    x_0=117;
    y_0=240;
    h=7.950352e+00;
end

% circular mask & ROI
[rx,ry,roix,roiy]=patch_mask(x_0,y_0,h,ROI_MULT,imageSizeX,imageSizeY);

% calculate the target model distribution (q)
q_u=color_distri(double(frame0),x_0,y_0,rx,ry,h);  
       

%% 3 - Run tracking algo.
%======================================================================
WRITEFILE=true; 

if WRITEFILE
    comps=strsplit(FILEPATH,'.');
    comps(1)=strcat(comps(1),'_result');
    path=strjoin(comps,'.');
    vid=VideoWriter(path);
    open(vid);
end

fprintf('# Running object tracking (%d-frames)\n',numberofframes);

%
% Iterate for each frame
%
iter_num = zeros(1,numberofframes);
center_x=x_0;
center_y=y_0;
for i=1:numberofframes  
    
    frame=double(mov(i).cdata);
       
    % mean-shift tracking iteration
    [x_0,y_0,p_u,iters]=mean_shift(frame,x_0,y_0,q_u,[roix-x_0 roiy-y_0],h,i);

    % circular mask & ROI [shifted]
    [rx,ry,roix,roiy]=patch_mask(x_0,y_0,h,ROI_MULT,imageSizeX,imageSizeY);

    % tracking center pos for overlay
    center_x=[center_x x_0];
    center_y=[center_y y_0];
    
    % overlay & display tracking results
    target_pos=mask_boundary([rx ry]);                  
    roi_pos=mask_boundary([roix roiy]); 
    
    frame=uint8(im_overlay(frame,[center_x],[center_y],target_pos,roi_pos));    
                 
    % keep iteration count
    iter_num(i)=iters; 
    
    % write OR show frame
    if WRITEFILE    
        writeVideo(vid,frame);
    else            
        figure(1);
        imshow(frame);title(['#Frame ',num2str(i),'/',num2str(numberofframes)]),drawnow; 
    end
  
end

% print result info
fprintf('# Total iterations    : %d\n',sum(iter_num));
fprintf('# Avg. iter per frame : %.2f\n',sum(iter_num)/numberofframes);

if WRITEFILE
    close(vid);
end