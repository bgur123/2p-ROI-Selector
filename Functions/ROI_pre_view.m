function out = ROI_pre_view(in,handles)

%% Reset axis
reset(handles.ROIaxes);
cla(handles.ROIaxes)
set(handles.ROIaxes,'XColor','none','YColor','none','TickDir','out')
grid on;

%% ------- Creating an average image from aligned frames for preview -------

nframes = in.xml.frames;
%Average image for channel1
AV = squeeze( sum( in.images_aligned,3 ) ) / nframes; % The average image for ch1
% Image_max = max( in.images_aligned,[],3 ) ; % The max image for ch1

% Plot the average image normalized
imagesc( AV , 'parent' , handles.ROIaxes );
titleStr = sprintf('Average image for Image %s',handles.imageNumberName);
title(titleStr)
colormap gray;

%% ------- Checking different image creation types, average image and max int image -------

% Not necessary anymore

% figure
% subplot(2,1,1)
% imagesc( AV );
% titleStr = sprintf('Average image for %s',handles.imageNumberName);
% title(titleStr)
% colormap gray;
% subplot(2,1,2)
% imagesc(Image_max);
% titleStr = sprintf('Maximum projection image for %s',handles.imageNumberName);
% title(titleStr)
% colormap gray;
