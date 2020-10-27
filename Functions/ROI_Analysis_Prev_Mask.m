function out = ROI_Analysis_Prev_Mask(in,handles)
%% Checks options
if isfield(in, 'BaseLine')
    baselineExist = 1;
else
    baselineExist = 0;
end

%% ------- Selecting the previous mask -------

% Selecting the image path
[~, imageNum] = fileparts(in.fileloc);
curDir = fullfile(handles.foldername,imageNum);
cd(curDir);

% Understanding the folder name structure for flexibility
beforeNum = regexp(imageNum, '\d','split');
beforeNumStr = beforeNum{1};
imageStr = [beforeNumStr num2str(handles.previousMaskImage)];

targetMaskDir = fullfile(handles.foldername ,imageStr);
cd(targetMaskDir);

% Loads the desired mask number from that image
try
    load(sprintf('curMasks%d.mat',handles.prevMaskNumROIsel));
catch error
    errordlg(sprintf('No masks available for %s', imageStr))
    return
    
end
% Goes back to the folder of the image of interest
cd(curDir);

%% -------------- ROI selection and saving --------------


layerCellChoice = questdlg('Add numbering of layer and cells as the previous image?');

switch layerCellChoice
    case 'Yes'
        
    case 'No'
        clear layer
        clear cellNumber
        layer = inputdlg( 'Enter the layer number within this fly' );
        layer = str2double(layer{1});
end


% Showing previous mask

show_mask(masks, in, handles)
% MASK SHOWING COMPLETE
NMasks = length(masks);

% Numbering the ROIs
for iMask = 1:NMasks
    [a b] = find(masks{iMask},1,'first')
    if exist('cellNumber') && strcmp(layerCellChoice,'Yes')
        plotText = sprintf('%d',cellNumber(iMask));
        text(b,a,plotText,'FontSize',24,'Color','r','Parent',handles.ROIaxes)
    elseif strcmp(layerCellChoice,'No')
        plotText = '-->';
        t = text(b,a,plotText,'FontSize',24,'Color','r','Parent',handles.ROIaxes);
        
        number = inputdlg('Please enter the current ROI number');
        number = str2double(number{1});
        set(t, 'String', number)
        cellNumber(iMask) = number;
    end
    

end

if exist('layer')
    title(sprintf('Layer: %d',layer),'Parent',handles.ROIaxes);
end
% ------- Want to move the whole mask?  -------
MoveMask = questdlg('Would you like to move whole mask together?');

switch MoveMask
    case 'Yes'
        masks = mask_mover(masks, in, handles);
        for iMask = 1:length(masks)
            [aaa, bbb] = find(masks{iMask},1,'first');

            plotText = sprintf('%d',cellNumber(iMask));
                text(bbb,aaa,plotText,'FontSize',24,'Color','r','Parent',handles.ROIaxes)
        end
end
% ------- Want to modify/delete ROIs?  -------

moveROI = questdlg('Would you like to modify or remove ROIs?');
x1 = 1;
switch moveROI
    case 'Yes'
        
        
        
        while ( ~isempty(x1) )
            title({'Press left click to modify ROI, right click to remove existing ROI';...
                'Press enter to exit'},'fontweight','bold');
            drawnow;
            [x1, y1, button] = ginput(1);
            y1 = round(y1);
            x1 = round(x1);%Finding the clicked pixel
            
            if button == 1
                % TO MODIFY
                xlabel({'Redraw the ROI'},'fontweight','bold');
%                 drawnow;
                ROIFound = 0;
                for indMask = 1:length(masks)
                    if masks{indMask}(y1, x1) %If pixel selected is in the mask
                        masks{indMask}(:) = 0 ;
                        show_mask(masks, in, handles)
                        while(~ROIFound)
                            masks{indMask} = roipoly; %Select the new mask
                            % if mistakenly clicked 1 or 2 points
                            if isempty(find(masks{ indMask }))
                                warning('Single point clicked, not taking ROI')
                                continue
                            end
                            ROIFound = 1;
                        end
                    end
                end
                if ~ROIFound
                    warning('ROI not found, please click on an existing ROI')
                    
                end
                
            elseif button == 3
                % TO DELETE
                title({'Deleting the ROI'},'fontweight','bold');
                drawnow;
                ROIFound = 0;
                for indMask = 1:length(masks)
                  
                    if masks{indMask}(y1, x1) %If pixel selected is in the mask
                        masks{indMask} = [];
                        cellNumber(indMask) = NaN; 
                        ROIFound = 1;
                        
                        
                    end
                end
                %create new masks by deleting one ROI
                nonEmptyIdx = find(~cellfun('isempty', masks));
                masks = masks(nonEmptyIdx);

                %create new cell numbers by deleting one ROI number
                nonEmptyCellIdx = find(~isnan(cellNumber)); 
                cellNumber = cellNumber(nonEmptyCellIdx);
                         
                if ~ROIFound
                    warning('ROI not found, please click on an existing ROI')
                end
                     
            end
            show_mask(masks, in, handles)
            for iMask = 1:length(masks)
                [aa, bb] = find(masks{iMask},1,'first');
               
                plotText = sprintf('%d',cellNumber(iMask));
                    text(bb,aa,plotText,'FontSize',24,'Color','r','Parent',handles.ROIaxes)
            end
            
        end
end




% ------- Want to add more ROIs?  -------

ROIChoice = questdlg('Would you like to add additional ROIs?');

switch ROIChoice
    case 'Yes'
        done = 0; 
        ROIindex = 1;
        while ( ~done )
            masks{ end + 1 } = roipoly;
            % if mistakenly clicked 1 or 2 points
            if isempty(find(masks{ end }))
                warning('Single point clicked, not taking ROI')
                continue
            end
            alphamask( masks{ end } , [1 1 1] , 0.33 );
            hold on ;
            done = waitforbuttonpress;
            %cellNumber
            if exist( 'currentCellNumber' )
                inputString = sprintf( 'Enter the ROI number -- Previous number: %d',...
                    currentCellNumber );
            else
                inputString ='Enter the ROI number'
            end
            currentCellNumber = inputdlg( inputString );
            currentCellNumber = str2num( currentCellNumber{1} );
            cellNumber( end + 1) = currentCellNumber;
            [ xx , yy ] = find( masks{ end }, 1 , 'first' )
            plotText = sprintf( '%d' , currentCellNumber );
            hold on ;
            text( yy , xx , plotText , 'FontSize' , 24 , 'Color' , 'r' )


            ROIindex = ROIindex + 1 ;
        end
end
nMasks = length(masks);


% ------- Save the masks and select background region if no previous exist --------
nframes = in.xml.frames;
if baselineExist
   
    nframesBaseLine = size(in.BaseLine, 3);
    BG = squeeze(sum(in.BaseLine,3))/nframesBaseLine; % Seb: The average image for BaseLine sequence
end

AV = squeeze(sum(in.ch1a,3))/nframes; %Average image

cd(curDir); 
d = dir('curMasks*.mat');
ind = length(d)+1;
if (ind == 1)
    switch handles.ImageShowType
    case 'Average image'    
        imagesc( AV , 'parent' , handles.ROIaxes );
    case 'Max proj. im.'
      
        imagesc(Image_max, 'parent' , handles.ROIaxes );
    end
    colormap gray;
    axes(handles.ROIaxes)
    title('select background region');
    NMask = roipoly;
else
    load('curMasks1.mat','NMask');
end

save(sprintf('curMasks%d',ind),'masks','NMask','nMasks','cellNumber','layer','categoryLabel','ROIsCategory');
fprintf('saved curMasks%d',ind);
cd(curDir);

%% Generate ratio signals from all regions of interest - aligned data
   
out = in;
out.layer = layer;
out.cellNumbers = cellNumber; 
out.masks = masks;
out.NMask = NMask;
out.categoryLabels = categoryLabel;
out.ROIsCategory = ROIsCategory;

out.avSignal1 = zeros(nMasks,nframes);
out.dSignal1 = zeros(nMasks,nframes);
% out.avSignal2 = zeros(nMasks,nframes);
% out.dSignal2 = zeros(nMasks,nframes);
out.ratio = zeros(nMasks,nframes);
out.dRatio = zeros(nMasks,nframes);

if baselineExist
    out.avSignalBG = zeros(nMasks,nframesBaseLine);
    out.dSignalBG = zeros(nMasks,nframesBaseLine);
    out.ratioBG = zeros(nMasks,nframesBaseLine);
    out.dRatioBG = zeros(nMasks,nframesBaseLine);
end

if(~isfield(in,'AV1'))
    AV1 = squeeze(sum(in.ch1a,3))/nframes; % The average image for ch1
    if baselineExist
        BG1 = squeeze(sum(in.BaseLine,3))/nframesBaseLine;
        out.BG1 = BG1;% seb: The average image for Baseline
    end
%     AV2 = squeeze(sum(in.ch2a,3))/nframes; % The average image for ch1
    out.AV1 = AV1;
   
%     out.AV2 = AV2;
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
sNmask = sum(sum(NMask));
Nmaski = find(NMask);

for ind = 1:nframes
    A = double(squeeze(in.ch1a(:,:,ind)));
%     B = double(squeeze(in.ch2a(:,:,ind)));
    for k = 1:nMasks

        masked = A(masksi{k});
        Nmasked = A(Nmaski);
        out.avSignal1(k,ind) = sum(masked)./smask(k);%ms: summed signal in a ROI, normalized by ROI size
        out.dSignal1(k,ind) = out.avSignal1(k,ind) - sum((Nmasked))./sNmask; %ms: background subtraction (by signal in background normalized by background ROI size)
        
%         masked = B(masksi{k});
%         Nmasked = B(Nmaski);
%         out.avSignal2(k,ind) = (sum(masked))./smask(k);
%         out.dSignal2(k,ind) = out.avSignal2(k,ind) - (sum(Nmasked))./sNmask;
    end
end

%Seb: I added the following lines to deal with the BaseLine variable
for k = 1:nMasks
    smask(k) = sum(sum(masks{k}));
    masksi{k}= find(masks{k});
end
sNmask = sum(sum(NMask));
Nmaski = find(NMask);

if baselineExist
    for ind = 1:nframesBaseLine
        B = double(squeeze(in.BaseLine(:,:,ind)));

        for k = 1:nMasks

            masked = B(masksi{k});
            Nmasked = B(Nmaski);
            out.avSignalBG(k,ind) = (sum(masked))./smask(k);
            out.dSignalBG(k,ind) = out.avSignalBG(k,ind) - (sum(Nmasked))./sNmask;


        end
    end
end


for i = 1:nMasks
    out.ratio(i,:) = out.avSignal1(i,:); %./out.avSignal2(i,:);
    out.dRatio(i,:) = out.dSignal1(i,:); %./out.dSignal2(i,:);
    
    if baselineExist
        
        out.ratioBG(i,:) = out.avSignalBG(i,:); %./out.avSignal2(i,:);
        out.dRatioBG(i,:) = out.dSignalBG(i,:); %./out.dSignal2(i,:);
    end
end

%% Bleaching analysis
% Analysis based on average signals, without background substraction

maxBleach = ones(2,1);
fdt = zeros(nMasks,1);
tdt = zeros(nMasks,1);

disp('bleaching info');
    disp(sprintf('neuron \t size \t ch1 b-rate \t ch2 b-rate \t ratio b-rate \t frac. dwell \t tot. dwell'));
for m = 1:nMasks
    % For every neuron
    bch = zeros(2,1);
    for ch = 1%:2
        % For every channel
        avSig = eval(sprintf('out.avSignal%d(m,:)',ch));
        LavSig = log(avSig);
        p = polyfit(1:nframes,LavSig,1); 
        bch(ch) = p(1);
%         % Display fitting results
%         figure;subplot(2,1,1);plot(LavSig);hold on;plot(polyval(p,1:nframes),'r');title(sprintf('log signal neuron %d channel %d, bleaching rate = %0.5g',m,ch,p(1)));
%         subplot(2,1,2);plot(avSig);hold
%         on;plot(exp(polyval(p,1:nframes)),'r');title(sprintf('original
%         signal neuron %d channel %d',m,ch));
        if (p(1)<maxBleach(ch))
            maxBleach(ch) = p(1);
            nBleach = m;
        end
    end
    % For the ratio
    avSig = out.ratio(m,:);
    LavSig = log(avSig);
    p = polyfit(1:nframes,LavSig,1);
%     % Display fitting results
%     figure;subplot(2,1,1);plot(LavSig);hold on;plot(polyval(p,1:nframes),'r');title(sprintf('log signal neuron %d ratio',m));
%     subplot(2,1,2);plot(avSig);hold
%     on;plot(exp(polyval(p,1:nframes)),'r');title(sprintf('original signal neuron %d ratio',m));
%     fdt(m) = in.xml.dwellt*10^-6*fps*smask(m);
%     tdt(m) = in.xml.dwellt*10^-6*smask(m)*nframes;
% %     disp(sprintf('neuron \t size \t ch1 b-rate \t ch2 b-rate \t ratio b-rate \t frac. dwell \t tot. dwell'));
%     disp(sprintf('%d \t %d \t %0.3g  \t %0.3g  \t %0.3g \t %0.3g \t %0.3g ',m,smask(m),bch(1),bch(2),p(1),fdt(m),tdt(m)));
end     

% disp(sprintf('mean fractional dwell time = %d',mean(fdt)));
% disp(sprintf('mean total dwell time = %d',mean(tdt)));
% disp(sprintf('CH1 - maximal bleaching rate = %d for neuron %d',maxBleach(1),nBleach));
% disp(sprintf('CH2 - maximal bleaching rate = %d for neuron %d',maxBleach(2),nBleach));

%% Noise analysis

% filter
[b,a] = butter(2,0.1);

disp('noise info - with background substraction');
disp(sprintf(['neuron \t ch1 noise \t ch2 noise \t ratio noise \t\t signal \t SNR']));
for m = 1:nMasks
    % For every neuron
    noise = zeros(2,1);
    for ch = 1%:2
        % For every channel
        dSig = eval(sprintf('out.dSignal%d(m,:)',ch));
%         figure;subplot(2,1,1);plot(dSig);hold on;
        sdSig = filtfilt(b,a,dSig);
%         plot(sdSig,'k','linewidth',2);title(sprintf('signal - neuron %d channel %d',m,ch));
        ndSig = dSig-sdSig;
%         subplot(2,1,2);plot(ndSig);title(sprintf('noise - neuron %d channel %d mean %0.5g std %0.5g',m,ch,mean(ndSig),std(ndSig)));
        noise(1,ch) = mean(ndSig);
        noise(2,ch) = std(ndSig);
    end
    % For ratio
    dSig = out.dRatio(m,:);
%     figure;subplot(2,1,1);plot(dSig);hold on;
    sdSig = filtfilt(b,a,dSig);
%     plot(sdSig,'k','linewidth',2);title(sprintf('signal - neuron %d ratio',m));
    ndSig = dSig-sdSig;
%     subplot(2,1,2);plot(ndSig);title(sprintf('noise - neuron %d ratio mean %0.5g std %0.5g',m,mean(ndSig),std(ndSig)));
%     disp(sprintf('%d \t %0.2g+/-%0.3g \t %0.2g+/-%0.3g \t %0.2g+/-%0.3g \t %0.3g \t %0.3g',m,noise(1,1),noise(2,1),noise(1,2),noise(2,2),mean(ndSig),std(ndSig),std(sdSig),std(sdSig)/std(ndSig)));
    disp(sprintf('%d \t %0.2g+/-%0.3g \t %0.2g+/-%0.3g \t %0.3g \t %0.3g',m,noise(1,1),noise(2,1),mean(ndSig),std(ndSig),std(sdSig),std(sdSig)/std(ndSig))); %ms, only one channel for GCamP
end

disp('noise info - without background substraction');
disp(sprintf(['neuron \t ch1 noise \t ch2 noise \t ratio noise \t\t signal \t SNR']));
for m = 1:nMasks
    % For every neuron
    noise = zeros(2,1);
    for ch = 1%:2
        % For every channel
        dSig = eval(sprintf('out.avSignal%d(m,:)',ch));
%         figure;subplot(2,1,1);plot(dSig);hold on;
        sdSig = filtfilt(b,a,dSig);
%         plot(sdSig,'k','linewidth',2);title(sprintf('signal - neuron %d channel %d',m,ch));
        ndSig = dSig-sdSig;
%         subplot(2,1,2);plot(ndSig);title(sprintf('noise - neuron %d channel %d mean %0.5g std %0.5g',m,ch,mean(ndSig),std(ndSig)));
        noise(1,ch) = mean(ndSig);
        noise(2,ch) = std(ndSig);
    end
    % For ratio
    dSig = out.ratio(m,:);
%     figure;subplot(2,1,1);plot(dSig);hold on;
    sdSig = filtfilt(b,a,dSig);
%     plot(sdSig,'k','linewidth',2);title(sprintf('signal - neuron %d ratio',m));
    ndSig = dSig-sdSig;
%     subplot(2,1,2);plot(ndSig);title(sprintf('noise - neuron %d ratio mean %0.5g std %0.5g',m,mean(ndSig),std(ndSig)));
%     disp(sprintf('%d \t %0.2g+/-%0.3g \t %0.2g+/-%0.3g \t %0.2g+/-%0.3g \t %0.3g \t %0.3g',m,noise(1,1),noise(2,1),noise(1,2),noise(2,2),mean(ndSig),std(ndSig),std(sdSig),std(sdSig)/std(ndSig)));
    disp(sprintf('%d \t %0.2g+/-%0.3g \t %0.2g+/-%0.3g \t %0.3g \t %0.3g',m,noise(1,1),noise(2,1),mean(ndSig),std(ndSig),std(sdSig),std(sdSig)/std(ndSig)));
end

cd(curDir)
