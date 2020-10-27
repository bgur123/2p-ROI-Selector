function out = FindCanROIs(in)


%% Automatically find candidate ROIs
% Miriam Henning (15.05.17)

nframes = in.xml.frames;
fps = in.xml.framerate;


ch1a=in.ch1a;
Baseline=in.BaseLine; % this baseline is the pixelwise response
% to 100 frames to preceeding the stimulus


REF=mean(Baseline,3); %baseline (REF) value calculated for each Pixel from 100 grey image presentation
dF=zeros(size(ch1a));

for p=1:size(ch1a,3)    % normalize to Basline activity of each Pixel (dF/F)
    F=(ch1a(:,:,p))./REF-1;
    dF(:,:,p)=F;
end

%% thresholding using Otsu' method, to identify pixels eligible for further analysis
%(non background pixels)
%   The algorithm assumes that the image contains two classes of pixels following bi-modal
%   histogram (foreground pixels and background pixels), it then calculates the optimum
%   threshold separating the two classes so that their combined spread (intra-class variance)
%   is minimal, or equivalently (because the sum of pairwise squared distances is constant),
%   so that their inter-class variance is maximal.

maxInt=max(ch1a,[],3); %Maximum Intensity Projection 
GF=imgaussfilt(maxInt,1.5);
%GF=maxInt;
[level, em] = graythresh(GF);

BW = im2bw(GF,level);
figure, imshow(BW)
%BW = ones(size(BW));
%% Separate recorded trace into traces of certain directions of moving stim

fstimval=in.fstimval; % average stimulus value per recorded frame

%Calculate average duration of each stimulus epoch
changes=diff(fstimval);
%ch=find(changes);
start_epoch=find(changes>0)+1;
end_epoch=find(changes<0);

dur=diff([start_epoch(1:length(end_epoch)),end_epoch]');
avdur=min(dur);
ep_all=nan(size(end_epoch,1), avdur); %ep_all contains the range of frames belonging to each stimulus epoch


for pp=1:length(end_epoch) 
    epoch=start_epoch(pp):start_epoch(pp)+avdur-1;
    ep_all(pp,:)=epoch;
end
ep_all=ep_all';
dur=avdur;


%% Calculate DSI, Pdir, ON/OFF resp
% Compare each pixel reponse strength to one of the 4 directions of movements

DSI=nan((size(ch1a(:,:,1)))); % will contain a Direction Selectivity Index for each Pixel
Pdir=nan((size(ch1a(:,:,1)))); % will contain the preferred Direction of each Pixel
TRespPD=nan(size(ch1a(:,:,1))); % will contain the timing of the Peak response to PD of each Pixel (relative to Stimulus onset)
MaxRespPD=nan(size(ch1a(:,:,1))); % will contain the Maximum of the Peak response to PD of each Pixel
ONorOFFpixel=nan(size(ch1a(:,:,1))); % will contain 0 for OFF (T5) and 1 for ON (T4) pixel

nomovement=find(diff(in.fstimpos1((ep_all(:,1))))==0);
Resp_PDperPixel=nan(size(ch1a,1),size(ch1a,2),length(1:nomovement(1)-1));
RT=[]; %nan((size(ch1a(:,:,1)))); % will contain a Response Timing for each Pixel

for p=1:size(ch1a,1)
    for pp=1:size(ch1a,2)
        
        if BW(p,pp)==1  %Calculate a DSI for each Pixel
            
            presp=squeeze(ch1a(p,pp,:));
            
            % average traces belonging to the same direction of movement
            Stim=fstimval(ep_all(2,:)); %Stimulus direction during all epochs 
            
            presp_dir=nan(avdur,4); %initiate matrix
            
            for kk=1:4 % loop through 4 directions of moving stim
                Double=find(Stim==kk);
                if length(Double)>1
                    allepochs=[];
                    for k=1:length(Double)
                        allepochs=[allepochs, presp(ep_all(:,Double(k)))];
                    end
                    presp_dir(:,kk)=mean(allepochs,2);
                elseif length(Double)==0;
                    disp(['Error: No Stiumulus Type ' num2str(kk),' found, Stimulus length was too short!!!']);
                else
                    presp_dir(:,kk)= presp(ep_all(:,Double));
                    
                end
            end
            
            threshold=std([presp_dir(:,1);presp_dir(:,2);presp_dir(:,3);presp_dir(:,4)]); %threshold that defines if maximum response of Pixel counts as a 'Response'
            % Check for responsivity
            
            
            responsivity = zeros(1,4);
            for u=1:4
                %if max(presp_dir(:,u))> 5*std(presp_dir(:,u))
                if max(presp_dir(:,u))> 6*threshold
                    responsivity(u)=1;
                   [Max,RT_i]=max(presp_dir(:,u));
                   RT=[RT,RT_i];
                end
            end
            
            if sum(responsivity)>0 % Only if a response to moving edge is at least visible to one
                % direction
                
                MAXdir=max(presp_dir);
                [MAX,PD]=max(MAXdir);
                % Calculate DSI by subtracting the ND=opposite direction of the PD = direction with maximal response
                if     PD==1;
                    ND=3;
                elseif PD==2;
                    ND=4;
                elseif PD==3;
                    ND=1;
                elseif PD==4;
                    ND=2;
                end
                
                DSI(p,pp)=(MAXdir(PD)-MAXdir(ND))/MAXdir(PD);
                
                %DSI(p,pp)=(max(MAXdir)-min(MAXdir))/(max(MAXdir));
                
                
                Pdir(p,pp)= PD;
                
                [M,Timing]=max(presp_dir(:,PD));  %hier vll noch intensity of response als Value dazu nehmen?
                TRespPD(p,pp)=Timing;
                MaxRespPD(p,pp)=M;
                
            end
            
            
            % Now I just  try to half the Stimulus trace to divide into ON\OFF pixels (T4/T5)
            
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % Better would be to look into the C++ code and look how edge stimkus is
            % createt to know at which time point I have dark and when light edge
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            % my hypothesis is that ON edge and OFF edge should be HALF /HALF of the
            % stimulus (before I have to subtract the part where stimulus is not moving
            
            stimuluspos=in.fstimpos1;
            
            
            stimulus=stimuluspos(ep_all(:,1));
            nomove=find(diff(stimulus)==0);   %finds the index where the position of the stimulus does not change(thus the stimulus is not moving)
            
            Presp_nomov=presp_dir(1:nomove(1)-1,:);  %cuts off the part of response trace where the stimulus is not moving
            
            %Stimulusnomov=stimulus(1:nomove(1)-1,:); %to check if cut out correctly
            
            
            OFFedge=Presp_nomov(1:round(length(Presp_nomov)/2),:);
            ONedge= Presp_nomov(round(length(Presp_nomov)/2+1):length(Presp_nomov),:);
            
            % Now separate pixels based on ON or OFF responses
            % Write a matrix containing a 0 for OFF and 1 for ON response
            % Compare response to PD between ON and OFF
            if Pdir(p,pp)>0
                PDresp_OFF=OFFedge(:,Pdir(p,pp)); % take out preferred direction response
                PDresp_ON=ONedge(:,Pdir(p,pp));
                %save Responses of each pixel to PD
                
                
                Resp_PDperPixel(p,pp,:)=Presp_nomov(:,Pdir(p,pp));
                
                
                if max(PDresp_OFF)>max(PDresp_ON);
                    
                    ONorOFFpixel(p,pp)=0;
                    
                    
                    
                elseif max(PDresp_OFF)< max(PDresp_ON);
                    
                    ONorOFFpixel(p,pp)=1;
                    
                    
                end
            end
            
            
        end
    end
end



%% Now we use the Components that decribe each Pixel Response (calculated above)
% DSI = Direction Selectivity Index
% Pdir = Preferred Direction
% TRespPD = Timing of Response to PD
% MaxRespPD = Maximum of Response to PD
% ONorOFFpixel = T4 ot T5 cell
% X &
% Y position

% to define a valuable size of ROIs fitting to the visual field of one T4/T5 cell
% we need to know the pixelsize\resolution of our images:

micronsX=str2num(in.xml.micronsPerPixel.XAxis);
micronsY=str2num(in.xml.micronsPerPixel.YAxis);

% Define ROI size
if micronsX==micronsY
    N_Pi_perROI= round(1/micronsX)* round(1/micronsX); 
%Size of individual axon Terminals is 1 micron (Takemura et al., 2013)

    
else
    disp('Pixel resolution in X and Y is not equal ')
    N_Pi_perROI_X= round(1/micronsX);
    N_Pi_perROI_Y= round(1/micronsY);
    
end

% calculate cluster analysis separated for Layers and ON/OFF pixel

A=DSI>0.3;
B_L1=(Pdir==1);
B_L2=(Pdir==2);
B_L3=(Pdir==3);
B_L4=(Pdir==4);
D_ON=(ONorOFFpixel==1);
D_OFF=(ONorOFFpixel==0);


ALL_L1_ON=A.*B_L1.*D_ON;
[relevantPixel_X_L1_ON,relevantPixel_Y_L1_ON]=find(ALL_L1_ON);

ALL_L2_ON=A.*B_L2.*D_ON;
[relevantPixel_X_L2_ON,relevantPixel_Y_L2_ON]=find(ALL_L2_ON);

ALL_L3_ON=A.*B_L3.*D_ON;
[relevantPixel_X_L3_ON,relevantPixel_Y_L3_ON]=find(ALL_L3_ON);

ALL_L4_ON=A.*B_L4.*D_ON;
[relevantPixel_X_L4_ON,relevantPixel_Y_L4_ON]=find(ALL_L4_ON);


ALL_L1_OFF=A.*B_L1.*D_OFF;
[relevantPixel_X_L1_OFF,relevantPixel_Y_L1_OFF]=find(ALL_L1_OFF);

ALL_L2_OFF=A.*B_L2.*D_OFF;
[relevantPixel_X_L2_OFF,relevantPixel_Y_L2_OFF]=find(ALL_L2_OFF);

ALL_L3_OFF=A.*B_L3.*D_OFF;
[relevantPixel_X_L3_OFF,relevantPixel_Y_L3_OFF]=find(ALL_L3_OFF);

ALL_L4_OFF=A.*B_L4.*D_OFF;
[relevantPixel_X_L4_OFF,relevantPixel_Y_L4_OFF]=find(ALL_L4_OFF);

% -------------------------------------------------------------------------

Components_L1_OFF=nan(length(relevantPixel_X_L1_OFF),3);
Components_L1_OFF(:,1)= relevantPixel_X_L1_OFF;
Components_L1_OFF(:,2)= relevantPixel_Y_L1_OFF;
for ll=1:length(relevantPixel_X_L1_OFF)
    Components_L1_OFF(ll,3)=TRespPD(relevantPixel_X_L1_OFF(ll),relevantPixel_Y_L1_OFF(ll));
end

Components_L2_OFF=nan(length(relevantPixel_X_L2_OFF),3);
Components_L2_OFF(:,1)= relevantPixel_X_L2_OFF;
Components_L2_OFF(:,2)= relevantPixel_Y_L2_OFF;
for ll=1:length(relevantPixel_X_L2_OFF)
    Components_L2_OFF(ll,3)=TRespPD(relevantPixel_X_L2_OFF(ll),relevantPixel_Y_L2_OFF(ll));
end

Components_L3_OFF=nan(length(relevantPixel_X_L3_OFF),3);
Components_L3_OFF(:,1)= relevantPixel_X_L3_OFF;
Components_L3_OFF(:,2)= relevantPixel_Y_L3_OFF;
for ll=1:length(relevantPixel_X_L3_OFF)
    Components_L3_OFF(ll,3)=TRespPD(relevantPixel_X_L3_OFF(ll),relevantPixel_Y_L3_OFF(ll));
end

Components_L4_OFF=nan(length(relevantPixel_X_L4_OFF),3);
Components_L4_OFF(:,1)= relevantPixel_X_L4_OFF;
Components_L4_OFF(:,2)= relevantPixel_Y_L4_OFF;
for ll=1:length(relevantPixel_X_L4_OFF)
    Components_L4_OFF(ll,3)=TRespPD(relevantPixel_X_L4_OFF(ll),relevantPixel_Y_L4_OFF(ll));
end

Components_L1_ON=nan(length(relevantPixel_X_L1_ON),3);
Components_L1_ON(:,1)= relevantPixel_X_L1_ON;
Components_L1_ON(:,2)= relevantPixel_Y_L1_ON;
for ll=1:length(relevantPixel_X_L1_ON)
    Components_L1_ON(ll,3)=TRespPD(relevantPixel_X_L1_ON(ll),relevantPixel_Y_L1_ON(ll));
end

Components_L2_ON=nan(length(relevantPixel_X_L2_ON),3);
Components_L2_ON(:,1)= relevantPixel_X_L2_ON;
Components_L2_ON(:,2)= relevantPixel_Y_L2_ON;
for ll=1:length(relevantPixel_X_L2_ON)
    Components_L2_ON(ll,3)=TRespPD(relevantPixel_X_L2_ON(ll),relevantPixel_Y_L2_ON(ll));
end

Components_L3_ON=nan(length(relevantPixel_X_L3_ON),3);
Components_L3_ON(:,1)= relevantPixel_X_L3_ON;
Components_L3_ON(:,2)= relevantPixel_Y_L3_ON;
for ll=1:length(relevantPixel_X_L3_ON)
    Components_L3_ON(ll,3)=TRespPD(relevantPixel_X_L3_ON(ll),relevantPixel_Y_L3_ON(ll));
end

Components_L4_ON=nan(length(relevantPixel_X_L4_ON),3);
Components_L4_ON(:,1)= relevantPixel_X_L4_ON;
Components_L4_ON(:,2)= relevantPixel_Y_L4_ON;
for ll=1:length(relevantPixel_X_L4_ON)
    Components_L4_ON(ll,3)=TRespPD(relevantPixel_X_L4_ON(ll),relevantPixel_Y_L4_ON(ll));
end

% 
% ClusterAnalysis is a function that calculates the best suitable 'maxclust'variable
% based on the defined Size of the ROIs (size of axon Terminals)
ValidClusters_L1_OFF= ClusterAnalysis_2(Components_L1_OFF,N_Pi_perROI,in);
ValidClusters_L2_OFF= ClusterAnalysis_2(Components_L2_OFF,N_Pi_perROI,in);
ValidClusters_L3_OFF= ClusterAnalysis_2(Components_L3_OFF,N_Pi_perROI,in);
ValidClusters_L4_OFF= ClusterAnalysis_2(Components_L4_OFF,N_Pi_perROI,in);

ValidClusters_L1_ON= ClusterAnalysis_2(Components_L1_ON,N_Pi_perROI,in);
ValidClusters_L2_ON= ClusterAnalysis_2(Components_L2_ON,N_Pi_perROI,in);
ValidClusters_L3_ON= ClusterAnalysis_2(Components_L3_ON,N_Pi_perROI,in);
ValidClusters_L4_ON= ClusterAnalysis_2(Components_L4_ON,N_Pi_perROI,in);



% % ValidClusters_L1_OFF= ClusterAnalysis_old(Components_L1_OFF,N_Pi_perROI,in);
% % ValidClusters_L2_OFF= ClusterAnalysis_old(Components_L2_OFF,N_Pi_perROI,in);
% % ValidClusters_L3_OFF= ClusterAnalysis_old(Components_L3_OFF,N_Pi_perROI,in);
% % ValidClusters_L4_OFF= ClusterAnalysis_old(Components_L4_OFF,N_Pi_perROI,in);
% % 
% % ValidClusters_L1_ON= ClusterAnalysis_old(Components_L1_ON,N_Pi_perROI,in);
% % ValidClusters_L2_ON= ClusterAnalysis_old(Components_L2_ON,N_Pi_perROI,in);
% % ValidClusters_L3_ON= ClusterAnalysis_old(Components_L3_ON,N_Pi_perROI,in);
% % ValidClusters_L4_ON= ClusterAnalysis_old(Components_L4_ON,N_Pi_perROI,in);


%% Plots for T5 (OFF Pixels)
% L1,L2...was assigned to the moveent directions 1 to 4 before
% here I now assign them correctly to the Layers therefore
% ValidClusters_L2_ON are clusters that belong to Layer 1 and movement
% direction 2. Sry its a bit confusing here :D
Try1=nan(size(DSI));
if length(ValidClusters_L2_OFF)>0

for i=1:length(ValidClusters_L2_OFF(:,1))
    ClusterType=ValidClusters_L2_OFF(i,3);
    Try1(ValidClusters_L2_OFF(i,1),ValidClusters_L2_OFF(i,2))=ClusterType;
end
masks_L1_OFF=cell(1,max(ValidClusters_L2_OFF(:,3)));

for ii=1:max(ValidClusters_L2_OFF(:,3))
    mask=zeros(size(DSI));
    mask(find(Try1==ii))=1;
    masks_L1_OFF{1,ii}=mask;
end


figure('Color', [1 1 1])
subplot(2,2,1)
imagesc(Try1)
colormap('colorcube')
title('Layer 1 - T5 ROIs')
else 
    
figure('Color', [1 1 1])
subplot(2,2,1)
text(0.2,0.5,'No valid clusters found')
masks_L1_OFF=[];

end 
%-----------------------------------------

Try1=nan(size(DSI));
if length(ValidClusters_L4_OFF)>0
for i=1:length(ValidClusters_L4_OFF(:,1))
    ClusterType=ValidClusters_L4_OFF(i,3);
    Try1(ValidClusters_L4_OFF(i,1),ValidClusters_L4_OFF(i,2))=ClusterType;
end
masks_L2_OFF=cell(1,max(ValidClusters_L4_OFF(:,3)));

for ii=1:max(ValidClusters_L4_OFF(:,3))
    mask=zeros(size(DSI));
    mask(find(Try1==ii))=1;
    masks_L2_OFF{1,ii}=mask;
end

subplot(2,2,2)
imagesc(Try1)
colormap('colorcube')
title('Layer 2 - T5 ROIs')

else 
subplot(2,2,2)
text(0.2, 0.5, 'No valid clusters found')
masks_L2_OFF=[];


end 

%-----------------------------------------

Try1=nan(size(DSI));
if length(ValidClusters_L1_OFF)>0
    
for i=1:length(ValidClusters_L1_OFF(:,1))
    ClusterType=ValidClusters_L1_OFF(i,3);
    Try1(ValidClusters_L1_OFF(i,1),ValidClusters_L1_OFF(i,2))=ClusterType;
end
masks_L3_OFF=cell(1,max(ValidClusters_L1_OFF(:,3)));

for ii=1:max(ValidClusters_L1_OFF(:,3))
    mask=zeros(size(DSI));
    mask(find(Try1==ii))=1;
    masks_L3_OFF{1,ii}=mask;
end

subplot(2,2,3)
imagesc(Try1)
colormap('colorcube')
title('Layer 3 - T5 ROIs')
else 
subplot(2,2,3)  
text(0.2, 0.5, 'No valid clusters found')
masks_L3_OFF=[];

end 
%-----------------------------------------

if length(ValidClusters_L3_OFF)>0;
    
Try1=nan(size(DSI));
for i=1:length(ValidClusters_L3_OFF(:,1))
    ClusterType=ValidClusters_L3_OFF(i,3);
    Try1(ValidClusters_L3_OFF(i,1),ValidClusters_L3_OFF(i,2))=ClusterType;
end
masks_L4_OFF=cell(1,max(ValidClusters_L3_OFF(:,3)));

for ii=1:max(ValidClusters_L3_OFF(:,3))
    mask=zeros(size(DSI));
    mask(find(Try1==ii))=1;
    masks_L4_OFF{1,ii}=mask;
end


subplot(2,2,4)
imagesc(Try1)
colormap('colorcube')
title('Layer 4 - T5 ROIs')
else 
subplot(2,2,4)
text(0.2, 0.5, 'No valid clusters found')
masks_L4_OFF=[];

    
end 
%-----------------------------------------

Try1=ones(size(DSI));
if length(ValidClusters_L2_OFF)>0
for i=1:length(ValidClusters_L2_OFF(:,1))
    ClusterType=ValidClusters_L2_OFF(i,3);
    Try1(ValidClusters_L2_OFF(i,1),ValidClusters_L2_OFF(i,2))=2;
end
end

if length(ValidClusters_L4_OFF)>0
for i=1:length(ValidClusters_L4_OFF(:,1))
    ClusterType=ValidClusters_L4_OFF(i,3);
    Try1(ValidClusters_L4_OFF(i,1),ValidClusters_L4_OFF(i,2))=3;
end
end

if length(ValidClusters_L1_OFF)>0
for i=1:length(ValidClusters_L1_OFF(:,1))
    ClusterType=ValidClusters_L1_OFF(i,3);
    Try1(ValidClusters_L1_OFF(i,1),ValidClusters_L1_OFF(i,2))=4;
end
end

if length(ValidClusters_L3_OFF)>0
for i=1:length(ValidClusters_L3_OFF(:,1))
    ClusterType=ValidClusters_L3_OFF(i,3);
    Try1(ValidClusters_L3_OFF(i,1),ValidClusters_L3_OFF(i,2))=5;
end
end

figure('Color', [1 1 1])
imagesc(Try1)
title('T5 cluster/ROIs')

%% Plot for T4 (ON pixels)

Try1=nan(size(DSI));
if length(ValidClusters_L2_ON)>0

for i=1:length(ValidClusters_L2_ON(:,1))
    ClusterType=ValidClusters_L2_ON(i,3);
    Try1(ValidClusters_L2_ON(i,1),ValidClusters_L2_ON(i,2))=ClusterType;
end
masks_L1_ON=cell(1,max(ValidClusters_L2_ON(:,3)));

for ii=1:max(ValidClusters_L2_ON(:,3))
    mask=zeros(size(DSI));
    mask(find(Try1==ii))=1;
    masks_L1_ON{1,ii}=mask;
end

figure('Color', [1 1 1])
subplot(2,2,1)
imagesc(Try1)
colormap('colorcube')
title('Layer 1 - T4 ROIs')
else
figure('Color', [1 1 1])
subplot(2,2,1)
text(0.2, 0.5, 'No valid clusters found')
masks_L1_ON=[];


end
%-----------------------------------------

Try1=nan(size(DSI));
if length(ValidClusters_L4_ON)>0
for i=1:length(ValidClusters_L4_ON(:,1))
    ClusterType=ValidClusters_L4_ON(i,3);
    Try1(ValidClusters_L4_ON(i,1),ValidClusters_L4_ON(i,2))=ClusterType;
end
masks_L2_ON=cell(1,max(ValidClusters_L4_ON(:,3)));

for ii=1:max(ValidClusters_L4_ON(:,3))
    mask=zeros(size(DSI));
    mask(find(Try1==ii))=1;
    masks_L2_ON{1,ii}=mask;
end

subplot(2,2,2)
imagesc(Try1)
colormap('colorcube')
title('Layer 2 - T4 ROIs')
else
subplot(2,2,2)
text(0.2, 0.5, 'No valid clusters found')
masks_L2_ON=[];

    
end
%-----------------------------------------

Try1=nan(size(DSI));
if length(ValidClusters_L1_ON)
for i=1:length(ValidClusters_L1_ON(:,1))
    ClusterType=ValidClusters_L1_ON(i,3);
    Try1(ValidClusters_L1_ON(i,1),ValidClusters_L1_ON(i,2))=ClusterType;
end

masks_L3_ON=cell(1,max(ValidClusters_L1_ON(:,3)));
for ii=1:max(ValidClusters_L1_ON(:,3))
    mask=zeros(size(DSI));
    mask(find(Try1==ii))=1;
    masks_L3_ON{1,ii}=mask;
end

subplot(2,2,3)
imagesc(Try1)
colormap('colorcube')
title('Layer 3 - T4 ROIs')

else 
subplot(2,2,3)
text(0.2, 0.5, 'No valid clusters found')
masks_L3_ON=[];


end 
%-----------------------------------------


Try1=nan(size(DSI));
if length(ValidClusters_L3_ON)>0
for i=1:length(ValidClusters_L3_ON(:,1))
    ClusterType=ValidClusters_L3_ON(i,3);
    Try1(ValidClusters_L3_ON(i,1),ValidClusters_L3_ON(i,2))=ClusterType;
end

masks_L4_ON=cell(1,max(ValidClusters_L3_ON(:,3)));

for ii=1:max(ValidClusters_L3_ON(:,3))
    mask=zeros(size(DSI));
    mask(find(Try1==ii))=1;
    masks_L4_ON{1,ii}=mask;
end

subplot(2,2,4)
imagesc(Try1)
colormap('colorcube')
title('Layer 4 - T4 ROIs')

else 
subplot(2,2,4)  
text(0.2, 0.5, 'No valid clusters found')
masks_L4_ON=[];


end 
%-----------------------------------------

Try1=ones(size(DSI));

if length(ValidClusters_L2_ON)>0
for i=1:length(ValidClusters_L2_ON(:,1))
    ClusterType=ValidClusters_L2_ON(i,3);
    Try1(ValidClusters_L2_ON(i,1),ValidClusters_L2_ON(i,2))=2;
end
end 

if length(ValidClusters_L4_ON)>0
for i=1:length(ValidClusters_L4_ON(:,1))
    ClusterType=ValidClusters_L4_ON(i,3);
    Try1(ValidClusters_L4_ON(i,1),ValidClusters_L4_ON(i,2))=3;
end
end

if length(ValidClusters_L1_ON)>0
for i=1:length(ValidClusters_L1_ON(:,1))
    ClusterType=ValidClusters_L1_ON(i,3);
    Try1(ValidClusters_L1_ON(i,1),ValidClusters_L1_ON(i,2))=4;
end
end

if length(ValidClusters_L3_ON)>0
for i=1:length(ValidClusters_L3_ON(:,1))
    ClusterType=ValidClusters_L3_ON(i,3);
    Try1(ValidClusters_L3_ON(i,1),ValidClusters_L3_ON(i,2))=5;
end
end

figure('Color', [1 1 1])
imagesc(Try1)
title('T4 cluster/ ROIs')


%% save masks of ROIs/individual clusters

curDir = pwd;

save('curMasks_CA','masks_L1_OFF','masks_L2_OFF','masks_L3_OFF','masks_L4_OFF','masks_L1_ON','masks_L2_ON','masks_L3_ON','masks_L4_ON');

disp(('saved curMasks_CA'));


%% Generate ratio signals from all regions of interest - aligned data

out = in;
out.masks_L1_OFF = masks_L1_OFF;
out.masks_L2_OFF = masks_L2_OFF;
out.masks_L3_OFF = masks_L3_OFF;
out.masks_L4_OFF = masks_L4_OFF;

out.masks_L1_ON = masks_L1_ON;
out.masks_L2_ON = masks_L2_ON;
out.masks_L3_ON = masks_L3_ON;
out.masks_L4_ON = masks_L4_ON;

% out.NMask = NMask;
nMasks=length(masks_L1_OFF)+length(masks_L2_OFF)+length(masks_L3_OFF)+length(masks_L4_OFF)+length(masks_L1_ON)+length(masks_L2_ON)+length(masks_L3_ON)+length(masks_L4_ON);
Layer=ones(length(masks_L1_OFF),1);
Layer=[Layer;2*ones(length(masks_L2_OFF),1)];
Layer=[Layer;3*ones(length(masks_L3_OFF),1)];
Layer=[Layer;4*ones(length(masks_L4_OFF),1)];

T4_T5=5*ones(length(Layer),1);
L=length(T4_T5);

Layer=[Layer;1*ones(length(masks_L1_ON),1)];
Layer=[Layer;2*ones(length(masks_L2_ON),1)];
Layer=[Layer;3*ones(length(masks_L3_ON),1)];
Layer=[Layer;4*ones(length(masks_L4_ON),1)];

T4_T5=[T4_T5;4*ones(length(Layer)-L,1)];

out.Layer=Layer;
out.T4_T5=T4_T5;
out.nMasks_CA=nMasks;

out.avSignal1_CA = zeros(nMasks,nframes);
out.dSignal1_CA = zeros(nMasks,nframes);
out.Epochs=ep_all;

masked = zeros(str2double(in.xml.linesPerFrame),str2double(in.xml.pixelsPerLine));
masks=[masks_L1_OFF,masks_L2_OFF,masks_L3_OFF,masks_L4_OFF,masks_L1_ON,masks_L2_ON,masks_L3_ON,masks_L4_ON];
smask = zeros(nMasks,1);
for k = 1:nMasks
    smask(k) = sum(sum(masks{k}));
    masksi{k}= find(masks{k});
end
out.masks_CA=masks;
NMask=zeros(size(DSI));
NMask(find (BW==0))=1;

sNmask = sum(sum(NMask));
Nmaski = find(NMask);

for ind = 1:nframes
    
    A = double(squeeze(in.ch1a(:,:,ind)));
    for k = 1:nMasks
        
        masked = A(masksi{k});
        Nmasked = A(Nmaski);
        out.avSignal1_CA(k,ind) = sum(masked)./smask(k); % summed signal in a ROI, normalized by ROI size
        out.dSignal1_CA(k,ind) = out.avSignal1_CA(k,ind) - sum((Nmasked))./sNmask; % background subtraction (by signal in background normalized by background ROI size)
        
    end
end






%% plot results
figure('Color', [1 1 1])
Pdir_im=Pdir;
Pdir_im(find(isnan(Pdir_im)==1))=0;

subplot(1,2,1)
imagesc(Pdir_im)
title('Preferred Direction')
subplot(1,2,2)
imagesc(DSI)
title('DSI')

%(range = (1+25):(length(t)-60); taken for dark edge presentation taken
%from movedges_figure_v1.m)
%Only take pixels with a DSI bigger than 0.3

P_DSItoosmall=find(DSI<0.3);
Pdirthresh=Pdir_im;
Pdirthresh(P_DSItoosmall)=0;
figure('Color', [1 1 1])
imagesc(Pdirthresh)
title('Preferred Direction- after DSI threshold')

%Example Pixel  :   [39 86] with DSI bigger than 0.5

%plot response

% % PiTryresp=(squeeze(ch1a(59,122,:)));
% %
% % piTryrespdir=zeros(size(ep_all)); % includes the response of this
% % %                pixel for all epochs of the different directions
% %
% %               for k=1:size(ep_all,2)
% %
% %               piTryrespdir(:,k)=PiTryresp(ep_all(:,k));
% %               end
% % figure
% % subplot(2,1, 1)
% % plot(piTryrespdir)
% % subplot(2,1, 2)
% % bar(max(piTryrespdir))

%% Plot ONOFFmatrix

ONorOFFpixel_im=ONorOFFpixel;

ONorOFFpixel_im(find(isnan(ONorOFFpixel_im)==1))=3;
figure('Color', [1 1 1]);
subplot(1,2,1)
imagesc(ONorOFFpixel_im);
title('Pixel assigned to ON (light blue) and OFF=(dark blue) -- before thresholding ')
DSI_Thresh=0.3;
P_DSItoosmall=find(DSI<DSI_Thresh);
PONOFFthresh=ONorOFFpixel_im;
PONOFFthresh(P_DSItoosmall)=3;

subplot(1,2,2)
imagesc(PONOFFthresh)
title(['-- after thresholding: DSI above ',num2str(DSI_Thresh)])



% Test if assignment of pixels worked out

% Plot ON and OFF edge responses for either pixels assigned to on or off
[OFFPixelsx,OFFPixelsy]=find(ONorOFFpixel==0);
[ONPixelsx,ONPixelsy]=find(ONorOFFpixel==1);
%[row,col]=find(...)

%plot randomly 5 Pixelresponses that were assigned to be OFF pixels
Rand_OFFp=round(length(OFFPixelsx)*rand(1,5))
Rand_ONp=round(length(ONPixelsx)*rand(1,5));

figure('Color', [1 1 1])
ii=1

for i=1:5;
    
    subplot(5,2,ii)
    Resp=squeeze(Resp_PDperPixel(OFFPixelsx(Rand_OFFp(i)),OFFPixelsy(Rand_OFFp(i)),:));
    Resp2=Resp/max(Resp);
    Resp2OFF=Resp2(round(1:length(Resp2)/2));
    Resp2ON=Resp2(round(length(Resp2)/2+1):length(Resp2));
    
    plot(Resp2OFF)
    hold on
    plot(Resp2ON)
    
    
    subplot(5,2,ii+1)
    Resp=squeeze(Resp_PDperPixel(ONPixelsx(Rand_ONp(i)),ONPixelsy(Rand_ONp(i)),:));
    Resp2=Resp/max(Resp);
    plot(Resp2)
    Resp2OFF=Resp2(1:round(length(Resp2)/2));
    Resp2ON=Resp2(round(length(Resp2)/2+1):length(Resp2));
    
    plot(Resp2OFF)
    hold on
    plot(Resp2ON)
    
    
    ii=ii+2;
    
end


subplot(5,2,1)
title('OFF pixels')
legend('Response to OFF edge', 'Response to ON edge')
subplot(5,2,2)
title('ON pixels')


cd(curDir)





%% This is the idea of using the cluster Analysis before seperating into Layer and ON FF Pixel (If we later want to use it)
% ... to calculate a cluster Analysis:
% % A=DSI>0.3;
% % B=~isnan(Pdir);
% % %C=MaxRespPD>0.09;
% % D=~isnan(ONorOFFpixel);
% %
% % CC=A.*B.*D;
% %
% % [relevantPixel_X,relevantPixel_Y]=find(CC);
% %
% %
% % Components=nan(length(relevantPixel_X),5);
% %
% % % for ll=1:length(relevantPixel_X)
% % %     Try(relevantPixel_X(ll),relevantPixel_Y(ll))=1;
% % % end
% % % imagesc(Try)
% % for ll=1:length(relevantPixel_X)
% %
% % %Components(ll,1)=DSI(relevantPixel_X(ll),relevantPixel_Y(ll));
% % Components(ll,1)=Pdir(relevantPixel_X(ll),relevantPixel_Y(ll));
% % Components(ll,2)=TRespPD(relevantPixel_X(ll),relevantPixel_Y(ll));
% % %Components(ll,4)=MaxRespPD(relevantPixel_X(ll),relevantPixel_Y(ll));
% % Components(ll,3)=ONorOFFpixel(relevantPixel_X(ll),relevantPixel_Y(ll));
% %
% % end
% %
% % Components(:,4)= relevantPixel_X;
% % Components(:,5)= relevantPixel_Y;
% %
% %
% %
% % % Euclidean distance of each pair of pixels
% % D=pdist(Components);
% %
% % Z=linkage(D, 'average')
% % P=cluster(Z,'maxclust',300)
% %
% % %dendrogram(Z)
% %
% % %Z=clusterdata(Components,50)
% %
% %
% % scatter(Components(:,5),Components(:,4)*-1,100,P,'filled','Colormap,','Colorcube')
% %
% %
% % % Other way to plot how the clustering worked out
% % Try1=nan(size(DSI));
% % for i=1:length(Z)
% %     ClusterType=Z(i);
% %     Try1(Components(i,6),Components(i,7))=ClusterType;
% % end
% %
% % imagesc(Try1)
