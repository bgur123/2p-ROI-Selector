function out = ROI_pre_view(in,handles)

%% ------- Creating an average image from ch1a (aligned frames)  for preview -------

nframes = in.xml.frames;
frameRate = in.xml.framerate;

%Average image for channel1
AV = squeeze( sum( in.ch1a,3 ) ) / nframes; % The average image for ch1

%Reset if the image size changed which happens for impulse flashes which
%has higher than 40 frame rate

    

% Plot the average image
imagesc( AV , 'parent' , handles.ROIaxes );

colormap gray;

