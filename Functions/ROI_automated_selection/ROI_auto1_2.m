function out = ROI_auto1_2(in, expectedROINumber, handles)

%% ------- Creating an average image from ch1a (aligned frames) -------

nframes = in.xml.frames;
nframesBaseLine = size(in.BaseLine, 3);



timeSeries = in.ch1a;

%% Set parameters
[d1,d2,T] = size(timeSeries);                                % dimensions of dataset
d = d1*d2;           

K = expectedROINumber;                            % number of components to be found
tau = 5;  % IN PIXEL                              % std of gaussian kernel (size of neuron) 
p = 2;                                            % order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
merge_thr = 0.8;                                  % merging threshold

options = CNMFSetParms(...                      
    'd1',d1,'d2',d2,...                         % dimensions of datasets
    'search_method','dilate','dist',3,...       % search locations when updating spatial components
    'min_size' , 3, 'max_size', 10, ...         % size of the ellipse
    'deconv_method','constrained_foopsi',...    % activity deconvolution method
    'temporal_iter',2,...                       % number of block-coordinate descent steps 
    'fudge_factor',0.98,...                     % bias correction for AR coefficients
    'merge_thr',merge_thr,...                    % merging threshold
    'gSig',tau...
    );

%% Data pre-processing
[P,timeSeries] = preprocess_data(timeSeries,p);

%% fast initialization of spatial components using greedyROI and HALS

[Ain,Cin,bin,fin,center] = initialize_components(timeSeries,K,tau,options,P);  % initialize

% display centers of found components
Cn =  correlation_image(timeSeries); %reshape(P.sn,d1,d2);  %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)

currentImage = imagesc(Cn);
currentImage.Parent = handles.ROIaxes;
fig = gcf;
currentAxes = gca
   axis equal; axis tight; hold all;
   scatter(center(:,2),center(:,1),'mo');
    title('Center of ROIs found from initialization algorithm');
    drawnow;
    
  

%% manually refine components (optional)
refine_components = true;  % flag for manual refinement
if refine_components
    [Ain,Cin,center] = manually_refine_components(timeSeries,Ain,Cin,center,Cn,tau,options, handles);
end

% STOP HERE WITH THE AUTO SELECTION SINCE THE REST IS 
%% Save masks


% Average image for channel1
AV = squeeze( sum( timeSeries,3 ) ) / nframes;
ROIindex = 1;
for ROIi = 1:size(Ain,2)
    currentAV = AV;
    currentROI = reshape(Ain(:,ROIi),options.d1,options.d2);
    indicesOfMask = find(currentROI);
    currentAV(:,:) = 0;
    currentAV(indicesOfMask) = 1;
    masks{ ROIi } = currentAV;
    ROIindex = ROIindex + 1;
    
end

nMasks = ROIindex - 1 ;

show_mask(masks, in, handles)
%% Number masks
layer = inputdlg( 'Enter the layer number within this fly' );
        layer = str2double(layer{1});

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
allGood = questdlg('All good?');
%%

% ------- Save the masks and select background region if no previous exist --------

curDir = pwd;
cd(in.fileloc); 
d = dir('curMasks*.mat');
cla(handles.ROIaxes ,'reset') % Needed to reset axis
ind = length(d)+1;
if (ind == 1)
    imagesc(AV,  'parent' , handles.ROIaxes );
    title('select background region');
    NMask = roipoly;
else
    load('curMasks1.mat','NMask');
end
% save(sprintf('curMasks%d',ind),'masks','NMask','nMasks');
% FOR CELL NUMBERS 
save(sprintf('curMasks%d',ind),'masks','NMask','nMasks','cellNumber','layer');
fprintf('saved curMasks%d',ind);
cd(curDir);

%% Generate ratio signals from all regions of interest - aligned data
   
out = in;
out.layer = layer;
out.cellNumbers = cellNumber; 
out.masks = masks;
out.NMask = NMask;
out.avSignal1 = zeros(nMasks,nframes);
out.dSignal1 = zeros(nMasks,nframes);
% out.avSignal2 = zeros(nMasks,nframes);
% out.dSignal2 = zeros(nMasks,nframes);
out.ratio = zeros(nMasks,nframes);
out.dRatio = zeros(nMasks,nframes);

out.avSignalBG = zeros(nMasks,nframesBaseLine);
out.dSignalBG = zeros(nMasks,nframesBaseLine);
out.ratioBG = zeros(nMasks,nframesBaseLine);
out.dRatioBG = zeros(nMasks,nframesBaseLine);

if(~isfield(in,'AV1'))
    AV1 = squeeze(sum(in.ch1a,3))/nframes; % The average image for ch1
    BG1 = squeeze(sum(in.BaseLine,3))/nframesBaseLine; % seb: The average image for Baseline
%     AV2 = squeeze(sum(in.ch2a,3))/nframes; % The average image for ch1
    out.AV1 = AV1;
    out.BG1 = BG1;
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

for ind = 1:nframesBaseLine
    B = double(squeeze(in.BaseLine(:,:,ind)));
    
    for k = 1:nMasks

        masked = B(masksi{k});
        Nmasked = B(Nmaski);
        out.avSignalBG(k,ind) = (sum(masked))./smask(k);
        out.dSignalBG(k,ind) = out.avSignalBG(k,ind) - (sum(Nmasked))./sNmask;
        
      
    end
end


for i = 1:nMasks
    out.ratio(i,:) = out.avSignal1(i,:); %./out.avSignal2(i,:);
    out.dRatio(i,:) = out.dSignal1(i,:); %./out.dSignal2(i,:);
    
    out.ratioBG(i,:) = out.avSignalBG(i,:); %./out.avSignal2(i,:);
    out.dRatioBG(i,:) = out.dSignalBG(i,:); %./out.dSignal2(i,:);
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
