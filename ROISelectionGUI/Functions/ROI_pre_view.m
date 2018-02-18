function out = ROI_pre_view(in,handles)

%% ------- Creating an average image from ch1a (aligned frames)  for preview -------

nframes = in.xml.frames;
%Average image for channel1
AV = squeeze( sum( in.ch1a,3 ) ) / nframes; % The average image for ch1

% Plot the average image
imagesc( AV , 'parent' , handles.ROIaxes );

colormap gray;

