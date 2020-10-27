%% Batch motion alignment of two-photon time series.
% This script performs the motion alignment of all folders of a selected subfolder.
%% Clean workspace.
close all;
clear all;

% extraction

alignment = 1 % doing alignment or not
wantMovie = false
reference_frame_num = 50
% Set MATLAB path.
addpath(genpath('/Users/burakgur/Desktop/MATLAB_Freya/Alignments'))
%% Choose folders to align.

raw_image_folder = uigetdir;
raw_d = struct2cell(dir(raw_image_folder));
raw_f_names = raw_d(1,:);
valid_raw_fNames = raw_f_names(contains(raw_f_names,'fly'));
fly_number = length(valid_raw_fNames);

for iFolder = 1:fly_number
    
    exp_directory = fullfile(raw_image_folder, valid_raw_fNames{iFolder});
    series_d = struct2cell(dir(exp_directory));
    series_names = series_d(1,:);
    series_names = series_names(contains(series_names,'TSeries'));
    series_num = length(series_names);
    
    for iSeries = 1:series_num
        series_name = series_names{iSeries};
        series_path = fullfile(exp_directory, series_name);
        cd(series_path);
        
        series_contents = struct2cell(dir(series_path)); 
        series_content_n = series_contents(1,:);
        images_folder = series_content_n(contains(series_content_n,'Series'));
        images_folder = images_folder{1};

        alignSingleTimeSeries(series_path, wantMovie, alignment, ...
            reference_frame_num)
    
         
        fprintf(sprintf('Alignment completed: %s -- %s\n',...
            valid_raw_fNames{iFolder}, series_name ))
    end
end
