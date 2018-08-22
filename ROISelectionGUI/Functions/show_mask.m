function show_mask(masks, in, handles)

NMasks = length(masks);


if exist('in.xml.linesperframe') && exist('in.xml.pixperline')
    CMask = zeros(in.xml.linesperframe, in.xml.pixperline, 3); % Luis 13.11.2015
else
    CMask = zeros(str2double(in.xml.linesPerFrame), str2double(in.xml.pixelsPerLine), 3);
end

% Comparing the compatibility of two images
example_previous_mask = masks{1};
[s1 s2] = size(example_previous_mask);
[s1n s2n ~] = size(CMask);

if ~(s1 == s1n) || ~(s2 == s2n)
    errordlg('Previous and current image dimensions do not match. Can''t proceed with superimposing masks')
end



cm = colormap(handles.ROIaxes,'lines');

for i = 1:NMasks
    curColor = cm(i,:);
    curMask = cat(3,curColor(1).*flipud(masks{i}),curColor(2).*flipud(masks{i}),curColor(3).*flipud(masks{i}));
    CMask = CMask + curMask;
end
nframes = in.xml.frames;

if(isfield(in,'AV1'))
    AV = in.AV1;
else
    %Average and max image for channel1 and BaseLine channel
    AV = squeeze( sum( in.ch1a,3 ) ) / nframes; % The average image for ch1
    Image_max = max( in.ch1a,[],3 ) ;
end



cla(handles.ROIaxes, 'reset')


% imageROI = imshow(AV,[],'parent',handles.ROIaxes);
switch handles.ImageShowType
    case 'Average image'    
        imagesc( AV , 'parent' , handles.ROIaxes );
    case 'Max int. proj.'
      
        imagesc(Image_max, 'parent' , handles.ROIaxes );
end



% Important for getting a gray average image and not colored since the
% function we used for getting a colormap for masks sets the color for the
% image to 'lines'
colormap(handles.ROIaxes,'gray');

hold(handles.ROIaxes,'on');
h = imagesc(flipud(CMask),'parent',handles.ROIaxes);
set(h,'AlphaData',0.3); %Make the masks a bit transparent to see the image