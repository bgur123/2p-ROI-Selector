clc;
clear all
close all;

% Single file analysis

addpath(genpath('/Users/mhennin2/Documents/MATLAB/TP_code_Miriam'))

i = 5;
%file = ['/Users/mhennin2/Documents/2p-imaging/170519/170519_Fly2/Image' num2str(i)];
%file = ['/Users/mhennin2/Documents/2p-imaging/170519/170519_Fly1/Image' num2str(i)];
%file = ['/Users/mhennin2/Documents/2p-imaging/170627/170627_Fly1/Image' num2str(i)];
file = ['/Users/mhennin2/Documents/2p-imaging/170420/170420_Fly1/Image' num2str(i)];
%file = ['/Users/mhennin2/Documents/2p-imaging/170629/170629_Fly1/Image' num2str(i)];

disp(file);
curDir = pwd;cd(file)

m = dir('data_file*');

if(~isempty(m))

    load('data_file');

    out = FindCanROIs(out); % still needs to be implemented 
    
    %out = ROI_gcamp_analysis(out,1); %true if you want to select ROIs
   
    out = FFFlash_res_display_1ch_mh(out, 2);  %Plots the results of ROI selection 
    %out = FFFlash_res_display_1ch(out, 2);  %Plots the results of ROI selection 

    save_processed_data_1ch_eni(out);%

    d = dir('_stimulus_*');
    fid = fopen(d.name,'r');
    currline = fgetl(fid);
    ind = strfind(currline,'\');
    disp(sprintf('stimulus: %s',currline(ind(end)+1:end)));
    fclose(fid);

else
    m = dir('*pData.mat');
    load(m.name);
    out = FFFlash_res_display_1ch(strct,2);
    ind = strfind(out.fileloc,'/'); %ms: mac modified
    ind2 = strfind(file,'/'); %ms: mac modified
    out.fileloc = [file(1:ind2(end)) out.fileloc((ind(end)+1):end)];
    save_processed_data_1ch(out);
    
end