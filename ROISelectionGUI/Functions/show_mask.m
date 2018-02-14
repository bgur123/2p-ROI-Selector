function show_mask(masks, in, handles)

NMasks = length(masks);


if exist('in.xml.linesperframe') && exist('in.xml.pixperline')
    CMask = zeros(in.xml.linesperframe, in.xml.pixperline, 3); % Luis 13.11.2015
else
    CMask = zeros(str2double(in.xml.linesPerFrame), str2double(in.xml.pixelsPerLine), 3);
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
    AV = squeeze(sum(in.ch1a,3))/nframes; % The average current image for ch1
end
cla(handles.ROIaxes, 'reset')
imageROI = imshow(AV,[],'parent',handles.ROIaxes);

hold(handles.ROIaxes,'on');
h = imshow(flipud(CMask),'parent',handles.ROIaxes);
set(h,'AlphaData',0.3); %Make the masks a bit transparent to see the image