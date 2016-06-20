%% Read
clc;
clear all;

% Create a VideoReader object to read data from the sample file.
% Then, determine the width and height of the video.
vid = VideoReader('assets/ellipse_slow_NEW.mpeg');
vidWidth = vid.Width;
vidHeight = vid.Height;

% Create a movie structure array, mov.
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);

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


%% Select ROI


startFrame=1;
endFrame=numberofframes;
% incre=input('Increased search size (5-15 is good): ');
incre=10;
% omega=input('Corrected area pararmeter (1-2 is good): ');
omega=1.5;

figure(1),imMask=roipoly(frame0); % get image mask
assert(size(imMask,1) > 0 && size(imMask,2) > 0, 'Select a ROI in the dialog!');
[ry,rx]=find(imMask);  % mask indicies
m0=floor(mean([rx,ry]))';  % mask center

%
% ellipse represented as covariance;
% http://www.visiondummy.com/2014/04/draw-error-ellipse-representing-covariance-matrix/
%
v0=cov([rx,ry]);  % covariance
v0=correctCov(v0,size(rx,1));

% mask center position
x_0=m0(1);
y_0=m0(2);

% image size
imgHeight=size(frame0,1);
imgWidth=size(frame0,2);

% calculate the target model distribution
q_u=rgbPDF(double(frame0),x_0,y_0,rx,ry);

% enlarge cov; v0_searchRegion
v0_targetRegion=enlargeCov(v0,incre);


%% Run
SHOWFRAMES=false;
SAVERESULT=true;

if SAVERESULT
    vid=VideoWriter('assets/result.avi');
    open(vid);
end

%
% Iterate
%
iterNum = zeros(1,(endFrame-startFrame+1));
for i=startFrame:endFrame

    frame=double(mov(i).cdata);

    [searchRegion_pos,searchRegionKernel]=cov2Ellipse(v0_targetRegion);

    % mean-shift tracking iteration
    [x_0,y_0,v0_newRegion,BhattCoff,iterations,p_u]=rgbTracking(frame,...
    imgWidth,imgHeight,x_0,y_0,q_u,searchRegion_pos,searchRegionKernel,...
    omega,i);

    % keep iteration count
    iterNum(i)=iterations;

    % region & boundary
    targetRegion_pos=cov2Ellipse(v0_newRegion);
    searchRegion_pos=cov2Ellipse(v0_targetRegion);

    targetBoundary_pos=region_boundary(targetRegion_pos);
    searchBoundary_pos=region_boundary(searchRegion_pos);

    % overlay &display tracking results
    frame=uint8(im_overlay(frame,x_0,y_0,targetBoundary_pos,3));
    frame=uint8(im_overlay(frame,x_0,y_0,searchBoundary_pos,4));

    % show frames
    if SHOWFRAMES
        figure(1);
        imshow(frame);title(['MST ',num2str(i),'/',num2str(numberofframes)]),drawnow;
    end

    % write frame
    if SAVERESULT
        writeVideo(vid,frame);
    end

     % update target region
    v0_targetRegion=enlargeCov(v0_newRegion,incre);
end

if SAVERESULT
    close(vid);
end
