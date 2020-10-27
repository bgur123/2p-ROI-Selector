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

if ((nargin==2)&&(~isnumeric(roi_mode)))

    figure;imagesc(AV);colormap gray;
    title('press enter when done selecting ROIs');
    done = 0;
    index = 1;
    while (~done)
        masks{index} = roipoly;
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
out.ratio = zeros(nMasks,nframes);
out.dRatio = zeros(nMasks,nframes);

if(~isfield(in,'AV1'))
    AV1 = squeeze(sum(in.ch1a,3))/nframes; % The average image for ch1
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
sNmask = sum(sum(NMask));
Nmaski = find(NMask);

for ind = 1:nframes
    A = double(squeeze(in.ch1a(:,:,ind)));
    
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



cd(curDir)
