function stim_sorter(bigFname)
% Deletes the non-relevant stimuli files and puts the folder inside the corresponding


stim_folder = fullfile(bigFname,'stimuli');
raw_image_folder = fullfile(bigFname,'raw_data');

raw_d = struct2cell(dir(raw_image_folder));
raw_f_names = raw_d(1,:);
valid_raw_fNames = raw_f_names(contains(raw_f_names,'fly'));

stim_d = struct2cell(dir(stim_folder));
stim_f_names = stim_d(1,:);
valid_stim_fNames = stim_f_names(contains(stim_f_names,'Stim'));

for iImagingFolder = 1:length(valid_raw_fNames)
    
    curr_imaging_folder = valid_raw_fNames{iImagingFolder};
    curr_imaging_fName = fullfile(raw_image_folder,curr_imaging_folder);
    curr_stim_idx = find(contains(valid_stim_fNames,curr_imaging_folder));
    if isempty(curr_stim_idx)
        warning(sprintf("%s: stimulus folder doesn't exist...\n",...
            curr_imaging_folder))
        continue
    end
    
    curr_stim_f = valid_stim_fNames{curr_stim_idx};
    fstimname = fullfile(stim_folder,curr_stim_f);
    
    % Find the ones that are used with NIDAQ - synchronized with imaging
    curr_stim_d = struct2cell(dir(fstimname));
    curr_stim_fNames = curr_stim_d(1,:);
    nidaq_stim_bool = contains(curr_stim_fNames,'NIDAQ-True');
    mat_stim_bool = contains(curr_stim_fNames,'.mat');
    used_stim_idx = find(nidaq_stim_bool.*mat_stim_bool);
    
    % Check if the number matches the imaging folder numbers
    curr_imaging_d = struct2cell(dir(curr_imaging_fName));
    curr_imaging_dNames = curr_imaging_d(1,:);
    series_idx = find(contains(curr_imaging_dNames,'TSeries'));
    
    if length(series_idx) ~= length(used_stim_idx)
        warning(sprintf("%s: stimuli and imaging numbers do not match...\n",...
            curr_imaging_folder))
        continue
    end
        
    for iStim = 1:length(used_stim_idx)
        curr_stim_file = curr_stim_fNames{used_stim_idx(iStim)};
        curr_stim_loc =fullfile(fstimname,curr_stim_file);
        curr_image_loc = fullfile(curr_imaging_fName,...
            curr_imaging_dNames{series_idx(iStim)});
        movefile(curr_stim_loc, curr_image_loc)
    end
    
    fprintf(sprintf('%s: Sorting completed...\n',curr_imaging_folder))
end
end