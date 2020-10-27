function out = display_responses(in, handles)
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
    signal_plot = plot((1:nframes)/fps,in.roi_signals_noBGsub(i,:),...
        'color',cm(i,:),'Parent',ax1);hold on;
end

ax1.XLabel.String = 'time (sec)';
ax1.Title.String = 'ROI signals - before BG subtraction';


f2 = figure(2); 
ax2 = axes(f2);
for i = 1:nMasks
    s1 = plot((1:nframes)/fps,(in.roi_signals(i,:)/mean(...
        in.roi_signals(i,:)))+1*(i-1),'color',max(cm(i,:),.7),...
        'Parent',ax2);
    hold on;
    
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
ax2.Title.String = 'ROI signals - BG subtracted' ;
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

f3 = figure;
ax3 = axes(f3);
imagesc(in.AV1,'Parent',ax3);
colormap gray;
hold on;
h = imagesc(flipud(CMask),'Parent',ax3);
set(h,'AlphaData',0.5);
ax3.Title.String = sprintf('Mean image',...
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
end


