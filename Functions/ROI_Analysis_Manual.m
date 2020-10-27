function out = ROI_Analysis_Manual(in,handles)

%% Checks options
% Changing the axis to an external figure upon user request in GUI
if strcmp(handles.FigureType,'Free figures')
    figure
    realROIaxes = handles.ROIaxes;
    handles.ROIaxes = gca;
end

    
%% ------- Creating an average image from ch1a (aligned frames) -------

nframes = in.xml.frames;

%Average image for channel1 and BaseLine channel
AV = squeeze( sum( in.images_aligned,3 ) ) / nframes; % The average image for ch1
Image_max = max( in.images_aligned,[],3 ) ;
%% -------------- ROI selection and saving --------------


switch handles.ImageShowType
    case 'Average image'    
        imagesc( AV , 'parent' , handles.ROIaxes );
    case 'Max int. proj.'
      
        imagesc(Image_max, 'parent' , handles.ROIaxes );
end
colormap gray;

%Storing layer number information within fly to match ROIs in same layers
%with different stimuli
layer = inputdlg( 'Enter the layer number within this fly' );
layer = str2num( layer{ 1 } );
titleString = sprintf( 'Layer: %d, Press ENTER after selecting the last ROI'...
    , layer );
title( titleString );


% ------- Selecting ROIs manually -------

done = 0; 
ROIindex = 1;
axes(handles.ROIaxes)
while ( ~done )
    
    masks{ ROIindex } = roipoly;
    % if mistakenly clicked 1 or 2 points
    if isempty(find(masks{ ROIindex }, 1))
        warning('Single point clicked, not taking ROI')
        continue
    end
        
    alphamask( masks{ ROIindex } , [1 1 1] , 0.33 );
    hold on ;
    done = waitforbuttonpress;
    

    ROIindex = ROIindex + 1 ;
end
nMasks = ROIindex - 1 ;

% ------- Numbering ROIs -------

maskNumbering = questdlg('Would you like to auto numerate ROIs?');

switch maskNumbering
    case 'Yes'
        cellNumber = 1:nMasks;
        for iMask = 1:nMasks
            [a ,b] = find(masks{iMask},1,'first');
            
            plotText = sprintf('%d',cellNumber(iMask));
            text(b,a,plotText,'FontSize',24,'Color','r','Parent',handles.ROIaxes)
        end
        
        
    case 'No'
        for iMask = 1:nMasks
            [a ,b] = find(masks{iMask},1,'first');

            plotText = '-->';
            t = text(b,a,plotText,'FontSize',24,'Color','r','Parent',handles.ROIaxes);

            number = inputdlg('Please enter the current ROI number');
            number = str2double(number{1});
            set(t, 'String', number)
            cellNumber(iMask) = number;

        end
end

% ------- Select background region --------
questdlg('Now background will be selected');
[~, imageNum] = fileparts(in.fileloc);
currPath = fullfile(handles.foldername,imageNum);
cd(currPath);


switch handles.ImageShowType
case 'Average image'    
    imagesc( AV , 'parent' , handles.ROIaxes );
case 'Max proj. im.'

    imagesc(Image_max, 'parent' , handles.ROIaxes );
end
colormap gray;
axes(handles.ROIaxes)

title('select background region');
BGMask = roipoly;


% ------- Adding categories --------

for iMask = 1:nMasks 
    [a ,b] = find(masks{iMask},1,'first');

    plotText = sprintf('%d',cellNumber(iMask));
    text(b,a,plotText,'FontSize',24,'Color','r','Parent',handles.ROIaxes)
end
                 
numberOfCategories = inputdlg( 'Enter the number of diferent categories for your ROIs' );
numberOfCategories = str2num( numberOfCategories{ 1 } );
for iCategory = 1:numberOfCategories
    categoryLabel{iCategory} = inputdlg( sprintf('Enter the name of the category # %d',...
        iCategory) );
    ROIsCategory{iCategory} = inputdlg( sprintf('Enter the cells numbers belonging category # %d (ea., 1:5)',...
        iCategory)  );
end

% ------- Saving data --------
d = dir('masks_*.mat');
curr_mask_num = length(d)+1;
save(sprintf('masks_%d',curr_mask_num),'masks','BGMask','nMasks','cellNumber','layer','categoryLabel','ROIsCategory');
fprintf('Saved: masks_%d.mat\n',curr_mask_num);
cd(currPath);

%% Generate ratio signals from all regions of interest - aligned data
   
out = in;
out.layer = layer;
out.cellNumbers = cellNumber; 
out.masks = masks;
out.BGMask = BGMask;
out.categoryLabels = categoryLabel;
out.ROIsCategory = ROIsCategory;

out.roi_signals = zeros(nMasks,nframes);
out.roi_signals_noBGsub = zeros(nMasks,nframes);

if(~isfield(in,'AV1'))
    AV1 = squeeze(sum(in.images_aligned,3))/nframes; % The average image for ch1
    out.AV1 = AV1;
end


if exist('in.xml.linesperframe') && exist('in.xml.linesperframe') % Luis 13.11.2015
    masked = zeros(in.xml.linesperframe,in.xml.pixperline);
else
    masked = zeros(str2double(in.xml.linesPerFrame),str2double(in.xml.pixelsPerLine));
end
smask = zeros(nMasks,1);
for k = 1:nMasks
    smask(k) = sum(sum(masks{k}));
    masksi{k}= find(masks{k});
end
sBGmask = sum(sum(BGMask));
BGmaski = find(BGMask);

for curr_mask_num = 1:nframes
    A = double(squeeze(in.images_aligned(:,:,curr_mask_num)));
    for k = 1:nMasks
        masked = A(masksi{k});
        BGmasked = A(BGmaski);
        out.roi_signals_noBGsub(k,curr_mask_num) = sum(masked)./smask(k);
        out.roi_signals(k,curr_mask_num) = sum(masked)./smask(k) - sum((BGmasked))./sBGmask;
    end
end


%% 
cd(currPath)

% Taking back the original axis
if strcmp(handles.FigureType,'Free figures')
    handles.ROIaxes = realROIaxes;
end

