%% Folder organizer

% Organizes stimulus and imaging folders for batch alignment
% Stimulus folders should be named as Stim_FLYID - Fly ID should be
% written exactly the same as imaging folder Fly ID. FlyID is found by
% taking whatever is after the second underscore
% Example raw imaging folder name: 180816bg_fly1
% Example stimulus folder name: Stim_180816bg_fly1
%
% Written by Burak Gur

%% 
clear all;
close all;
addpath(genpath('/Users/burakgur/Documents/MATLAB/TP_code'))

dispStr = sprintf('-> Pick the folder where all stimuli and imaging data are\n');
disp(dispStr)

[bigFname]=uigetdir();
cd(bigFname)
%% Making imaging folders
folder_organizer(bigFname); %Organizes imaging folders

dispStr = sprintf('All imaging folders organized, proceeding to stimuli folders\n');
disp(dispStr)
%% Processing stimulus
stim_sorter(bigFname) %Organizes stimulus folders

dispStr = sprintf('\n\nImage and stimuli sorting is completed... \nPlease check the above log for WARNINGS\n');
disp(dispStr)

