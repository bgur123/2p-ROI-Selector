function  ROI_Show(imageData, maskFileNo, handles)

%% Create a colored map of ROIs
nframes = imageData.xml.frames;

% Checking if the user wants to see ROIs or not
if isfield(handles,'hide_roi')
    hide_roi = handles.hide_roi;
else
    hide_roi = 0;
end
% Finding and changing to image path
[~, imageNum] = fileparts(imageData.fileloc);
currPath = fullfile(handles.foldername,imageNum);
cd(currPath);

if hide_roi
    image_show(imageData, handles)
else
    
    % Loading masks
    load(sprintf('curMasks%d.mat',maskFileNo));
    NMasks = length(masks);


    if exist('in.xml.linesperframe') && exist('in.xml.pixperline')
        CMask = zeros(imageData.xml.linesperframe, imageData.xml.pixperline, 3); % Luis 13.11.2015
    else
        CMask = zeros(str2double(imageData.xml.linesPerFrame), str2double(imageData.xml.pixelsPerLine), 3);
    end

    % Generating a colormap for Masks
    cm = colormap(handles.showAxes,'lines');

    % Creating colored masks
    for i = 1:NMasks
        curColor = cm(i,:);
        curMask = cat(3,curColor(1).*flipud(masks{i}),curColor(2).*flipud(masks{i}),curColor(3).*flipud(masks{i}));
        CMask = CMask + curMask;
    end

    % Generating an average image to plot behind the masks
    if(isfield(imageData,'AV1'))
        AV = imageData.AV1;
    else
        AV = squeeze(sum(imageData.ch1a,3))/nframes; % The average image for ch1
        Image_max = max( imageData.ch1a,[],3 ) ;
    end

    % Plotting the average image
    reset(handles.showAxes);
    switch handles.ImageShowType
        case 'Average image'    
            imagesc( AV , 'parent' , handles.showAxes );
        case 'Max int. proj.'

            imagesc(Image_max, 'parent' , handles.showAxes );
    end
    % Important for getting a gray average image and not colored since the
    % function we used for getting a colormap for masks sets the color for the
    % image to 'lines'
    colormap(handles.showAxes,'gray');

    % Hold to plot both masks and average image together
    hold(handles.showAxes,'on');

    %Plotting the masks
    h = imagesc(flipud(CMask),'parent',handles.showAxes);

    %Numbering the masks
    for iMask = 1:NMasks
        [a b] = find(masks{iMask},1,'first');
        if exist('cellNumber')
            plotText = sprintf('%d',cellNumber(iMask));
            text(b,a,plotText,'FontSize',24,'Color','r','Parent',handles.showAxes)
        end


    end

    % Making masks transparent so that you can see the average image too
    set(h,'AlphaData',0.3);
    if exist('layer')
        title(sprintf('Layer: %d, Mask file: %d ',layer, maskFileNo),'Parent',handles.showAxes);
    end
end

