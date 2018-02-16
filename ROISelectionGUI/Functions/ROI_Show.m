function  ROI_Show(in, maskFileNo, handles)

%% Create a colored map of ROIs
nframes = in.xml.frames;

[~, imageNum] = fileparts(in.fileloc);
currPath = fullfile(handles.foldername,imageNum);
cd(currPath);

load(sprintf('curMasks%d.mat',maskFileNo));


NMasks = length(masks);


if exist('in.xml.linesperframe') && exist('in.xml.pixperline')
    CMask = zeros(in.xml.linesperframe, in.xml.pixperline, 3); % Luis 13.11.2015
else
    CMask = zeros(str2double(in.xml.linesPerFrame), str2double(in.xml.pixelsPerLine), 3);
end
cm = colormap(handles.showAxes,'lines');

for i = 1:NMasks
    curColor = cm(i,:);
    curMask = cat(3,curColor(1).*flipud(masks{i}),curColor(2).*flipud(masks{i}),curColor(3).*flipud(masks{i}));
    CMask = CMask + curMask;
end

if(isfield(in,'AV1'))
    AV = in.AV1;
else
    AV = squeeze(sum(in.ch1a,3))/nframes; % The average image for ch1
end

reset(handles.showAxes);
imageROI = imshow(AV,[],'parent',handles.showAxes);

hold(handles.showAxes,'on');
h = imshow(flipud(CMask),'parent',handles.showAxes);
for iMask = 1:NMasks
    [a b] = find(masks{iMask},1,'first')
    if exist('cellNumber')
        plotText = sprintf('%d',cellNumber(iMask));
        text(b,a,plotText,'FontSize',24,'Color','r','Parent',handles.showAxes)
    end
    

end


set(h,'AlphaData',0.3);
if exist('layer')
    title(sprintf('Layer: %d, Mask file: %d ',layer, maskFileNo),'Parent',handles.showAxes);
end


