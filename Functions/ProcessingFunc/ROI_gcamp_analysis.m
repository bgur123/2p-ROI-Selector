function out = ROI_gcamp_analysis(in,roi_mode)
%ms: modified to read one channel only from tnxxl version
%(ROI_tnxxl_analysis_LB2), 04/18/2013

%% Automatically choose ROIs

nframes = in.xml.frames;
fps = in.xml.framerate;

if(isfield(in,'AV1'))
    AV = in.AV1;
else
    AV = squeeze(sum(in.ch1a,3))/nframes; % The average image for ch1
end

if(nargin==1)||((nargin==2)&&(~roi_mode))
    
    figure;imagesc(AV);colormap gray;
    set(gca,'dataa',[1 1 1]);
    AV2=conv2(AV,ones(20)/400,'same');
    figure; imagesc(AV-AV2); colorbar;
    D = AV-AV2;

    DONE = 0;
    thresh = 0;
    but=1;
    md = imdilate(D > thresh,ones(3)); %% CAN INSERT OTHER THRESHOLD BASED ALGORITHM IN HERE. SUBTRACT LOCAL AVERAGE FIRST on m? see above.
    mdr = imerode(md,ones(3));
    figure;
    while ~DONE
        threshkeep = thresh; % just keep it, in case...
        buttonkeep = but;
        md = imdilate(D>thresh,ones(3));
        mdr = imerode(md,ones(3));

        subplot(2,1,1);
        hist(reshape(D,1,[]),200);
        set(gca,'yscale','log');
        subplot(2,1,2);
        imagesc(mdr); %colormap('gray');
        subplot(2,1,1);
        [thresh,dum,but] = ginput(1);
        DONE = (length(thresh)==0); % exit loop when return pressed...
    end
    mdrl = bwlabel(mdr);

    for i=1:max(max(mdrl))
        [ty,tx]=find(mdrl == i);
        cx(i)=mean(tx);
        cy(i)=mean(ty);
    end

    figure; imagesc(mdrl); hold on;
    plot(cx,cy,'ko');

    [x,y]=ginput;

    for i=1:length(x)
        d=(x(i)-cx).^2 + (y(i)-cy).^2;
        [dum,ch(i)]=min(d);
    end
    curLen = length(ch);
    
    % Repeat if necessary
    if (buttonkeep>1)
        figure;
        DONE = false;
        while ~DONE
            if(~isempty(thresh))
                threshkeep2 = thresh;                
            else
                thresh = threshkeep; 
            end
            md = imdilate(D>thresh,ones(3));
            mdr = imerode(md,ones(3));

            subplot(2,1,1);
            hist(reshape(D,1,[]),200);
            set(gca,'yscale','log');
            subplot(2,1,2);
            imagesc(mdr); %colormap('gray');
            subplot(2,1,1);
            [thresh,dum] = ginput(1);
            DONE = (length(thresh)==0); % exit loop when return pressed...
        end
        mdrl2 = bwlabel(mdr);

        for i=1:max(max(mdrl2))
            [ty,tx]=find(mdrl2 == i);
            cx(i)=mean(tx);
            cy(i)=mean(ty);
        end

        figure; imagesc(mdrl2); hold on;
        plot(cx,cy,'ko');

        [x,y]=ginput;

        for i=1:length(x)
            d=(x(i)-cx).^2 + (y(i)-cy).^2;
            [dum,ch(i+curLen)]=min(d);
        end
    end

    % generate masks
    nMasks = length(ch);
    masks = cell(length(ch),1);
    for i=1:length(ch)
        if(i<=curLen)
            curMask=imdilate(imdilate(mdrl == ch(i),ones(3)),ones(3)); % dilate
        else
            curMask=imdilate(imdilate(mdrl2 == ch(i),ones(3)),ones(3)); % dilate
        end
        masks{i} = curMask;
    end
    
elseif ((nargin==2)&&(~isnumeric(roi_mode)))

    figure;imagesc(AV);colormap gray;
    title('press enter when done selecting ROIs');
    done = 0;
    index = 1;
    while (~done)
        masks{index} = roipoly;
%         alphamask(masks{index}, [1 1 1], 0.33);
%         hold on ;
        done = waitforbuttonpress;

        index = index+1;
    end
    nMasks = index-1;

    curDir = pwd;
    cd(in.fileloc); % save masks in the T-series directory
    d = dir('curMasks*.mat');
    ind = length(d)+1;
    if (ind == 1)
        figure;imagesc(AV);colormap gray;
        title('select background region');
        NMask = roipoly;
    else
        load('curMasks1.mat','NMask');
    end
else
    curDir = pwd;
    cd(in.fileloc);
    load(sprintf('curMasks%d.mat',roi_mode));
    cd(curDir);
end

curDir = pwd;
cd(in.fileloc); % save masks in the T-series directory
if ((nargin==1)||(~isnumeric(roi_mode)))
    d = dir('curMasks*.mat');
    ind = length(d)+1;
    if (ind == 1)
        figure;imagesc(AV);colormap gray;
        title('select background region');
        NMask = roipoly;
    else
        load('curMasks1.mat','NMask');
    end
    save(sprintf('curMasks%d',ind),'masks','NMask','nMasks');
    disp(sprintf('saved curMasks%d',ind));
end
cd(curDir);

%% Generate ratio signals from all regions of interest - aligned data
   
out = in;
out.masks = masks;
out.NMask = NMask;
out.avSignal1 = zeros(nMasks,nframes);
out.dSignal1 = zeros(nMasks,nframes);
% out.avSignal2 = zeros(nMasks,nframes);
% out.dSignal2 = zeros(nMasks,nframes);
out.ratio = zeros(nMasks,nframes);
out.dRatio = zeros(nMasks,nframes);

if(~isfield(in,'AV1'))
    AV1 = squeeze(sum(in.ch1a,3))/nframes; % The average image for ch1
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

for i = 1:nMasks
    out.ratio(i,:) = out.avSignal1(i,:)%./out.avSignal2(i,:);
    out.dRatio(i,:) = out.dSignal1(i,:)%./out.dSignal2(i,:);
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
