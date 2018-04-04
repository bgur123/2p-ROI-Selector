function out = ROI_pre_view(in,handles)

%% Reset axis
reset(handles.ROIaxes);
cla(handles.ROIaxes)
set(handles.ROIaxes,'XColor','none','YColor','none','TickDir','out')
grid on;

%% ------- Creating an average image from ch1a (aligned frames)  for preview -------

nframes = in.xml.frames;
%Average image for channel1
AV = squeeze( sum( in.ch1a,3 ) ) / nframes; % The average image for ch1

% Plot the average image normalized
imshow( AV ,[], 'parent' , handles.ROIaxes );
titleStr = sprintf('Average image for %s in channel 1',handles.imageNumberName);
title(titleStr)
colormap gray;

