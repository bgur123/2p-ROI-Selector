function out = FFFlash_res_display_BG_GUI(in,dur, handles)
%% Find stimulus timing - modify after clean-up script is written

out = in;
nframes = in.xml.frames;
fps = in.xml.framerate;

thresh = 0.5;
mask = out.fstimval>thresh;
dmask = mask(2:end)-mask(1:end-1);
dmask = [0; dmask];

%% Plot ratio signals from ROIs together with stimulus timing

nMasks = length(in.masks);

[~, imageNum] = fileparts(in.fileloc);
[~, flyID] = fileparts(handles.foldername);
flyImageID = [flyID '-' imageNum];

curDir = fullfile(handles.foldername,imageNum);
cd(curDir);


f1 = figure(1);
ax1 = axes(f1);
for i = 1:nMasks
    f1= figure(1);
    cm = colormap('lines');
    signal_plot = plot((1:nframes)/fps,in.avSignal1(i,:),...
        'color',cm(i,:),'Parent',ax1);hold on;
end

ax1.XLabel.String = 'time (sec)';
ax1.Title.String = 'Signal in region of interest - before background substraction, aligned data';


f2 = figure(2); 
ax2 = axes(f2);
for i = 1:nMasks
    s1 = plot((1:nframes)/fps,(in.dSignal1(i,:)/mean(...
        in.dSignal1(i,:)))+1*(i-1),'color',max(cm(i,:),.7),...
        'Parent',ax2);
    hold on;
    s2 = plot((1:nframes)/fps,in.dRatio(i,:)/mean(...
        in.dRatio(i,:))+1*(i-1),'color',cm(i,:),'linewidth',2,...
        'Parent',ax2);
end
stim_plot = plot((1:nframes)/fps,out.fstimval*0.2,'LineWidth',2,'Parent',ax2);


inds = find(dmask~=0);
for k = 1:length(inds)
    if(dmask(inds(k))>0)
        l1 = line([inds(k)/fps inds(k)/fps],[0 nMasks+1],...
            'color',cm(i,:),'LineWidth',1,'LineStyle','-',...
            'Parent',ax2);
    else
        l1 = line([inds(k)/fps inds(k)/fps],[0 nMasks+1],...
            'color',cm(i,:),'LineWidth',1,'LineStyle','--',...
            'Parent',ax2);
    end
    
    
end
ax2.XLabel.String = 'time (sec)';
ax2.Title.String = 'Ratio, YFP, CFP signals - aligned data' ;
ax2.XLim = [0 nframes/fps];
ax2.YLim = [ 0 i+1];
% Create a colored map of ROIs
if exist('in.xml.linesperframe') && exist('in.xml.pixperline')
    CMask = zeros(in.xml.linesperframe, in.xml.pixperline, 3); % Luis 13.11.2015
else
    CMask = zeros(str2double(in.xml.linesPerFrame), str2double(in.xml.pixelsPerLine), 3);
end

for i = 1:nMasks
    curColor = cm(i,:);
    curMask = cat(3,curColor(1).*flipud(in.masks{i}),curColor(2).*flipud(in.masks{i}),curColor(3).*flipud(in.masks{i}));
    CMask = CMask + curMask;
end

if(~isfield(in,'AV1'))
    AV = squeeze(sum(in.ch1a,3))/nframes; % The average image
    AV = im2double(AV);
    AV = AV./max(AV(:));
else
    AV = in.AV1;
end
f3 = figure;
ax3 = axes(f3);
imagesc(AV,'Parent',ax3);
colormap gray;
hold on;
h = imagesc(flipud(CMask),'Parent',ax3);
set(h,'AlphaData',0.5);
ax3.Title.String = sprintf('average aligned image at z-depth %0.5g microns',...
    in.xml.zdepth);


%% Saving figures
SaveFigChoice = questdlg('Would you like to save figures?');
switch SaveFigChoice
    case 'Yes'
        fig3Name = sprintf('%s Masks',flyImageID);
        savefig(f3, fig3Name)
        fig2Name = sprintf('%s BS Traces',flyImageID);
        savefig(f2, fig2Name)
        fig1Name = sprintf('%s RawTrace',flyImageID);
        savefig(f1, fig1Name)
        fprintf('\n Figures saved... \n')
        
    case 'No'
        fprintf('\n Figures not saved... \n')
end


% %% Z-stack analysis
% 
% if 0
% curDir = pwd;
% cd(in.fileloc);
% [fname,pathname]=uigetfile('*','Choose the corresponding z-stack...');
% cd(curDir);
% if fname ~= 0
%     z=read_z_stack(pathname);    
% else
%     return;
% end
% 
% %here
% zd=z.xml.zdepth;
% [dum,choose]=min(abs(zd-in.xml.zdepth));
% 
% figure; hold on;
% imagesc(squeeze(z.ims(:,:,choose))); colormap('gray');
% plot(20+[0 50/z.xml.xres],(size(z.ims,1)-25)*[1 1],'color',ones(1,3),'linewidth',3);
% title(['Z = ' num2str(zd(choose)) ' microns, ' num2str(zd(choose)-zd(1)) ' microns from the top']);
% set(gca,'data',[1 1 1],'xtick',[],'ytick',[],'xlim',[0 size(z.ims,2)],'ylim',[0 size(z.ims,1)],'ydir','normal');
% 
% [xin,yin]=ginput;
% y1=round(min(yin)); y2=round(max(yin));
% x1=round(min(xin)); x2=round(max(xin));
% maxproj=squeeze(max(z.ims(y1:y2,x1:x2,:),[],1))';
% figure; hold on;
% imagesc(maxproj); colormap('gray');
% plot([1 size(maxproj,2)],choose*[1 1],'color',ones(1,3),'linewidth',2);
% plot(20+[0 50/z.xml.xres],(size(maxproj,1)-5)*[1 1],'color',ones(1,3),'linewidth',3);
% set(gca,'xtick',[],'ytick',[],'xlim',[1 size(maxproj,2)],'ylim',[1 size(maxproj,1)],'ydir','reverse');
% set(gca,'data',[abs(zd(2)-zd(1)),z.xml.xres, 1]);
% 
% end
