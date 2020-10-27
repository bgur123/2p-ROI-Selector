function image_show(imageData,handles)

%% Reset axis
reset(handles.showAxes);
cla(handles.showAxes)
set(handles.showAxes,'XColor','none','YColor','none','TickDir','out')
grid on;

%% ------- Creating an average image from ch1a (aligned frames)  for preview -------

nframes = imageData.xml.frames;
%Average image for channel1
AV = squeeze( sum( imageData.ch1a,3 ) ) / nframes; % The average image for ch1
Image_max = max( imageData.ch1a,[],3 ) ; % The max image for ch1

% Plot the desired image normalized
switch handles.ImageShowType
    case 'Average image'    
        imagesc( AV , 'parent' , handles.showAxes );
    case 'Max int. proj.'
      
        imagesc(Image_max, 'parent' , handles.showAxes );
end


colormap gray;

