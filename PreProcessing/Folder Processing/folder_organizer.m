function folder_organizer(bigFname)
% Organizes imaging folders 

raw_image_folder = fullfile(bigFname,'raw_data');

raw_d = struct2cell(dir(raw_image_folder));
raw_f_names = raw_d(1,:);
valid_raw_fNames = raw_f_names(contains(raw_f_names,'fly'));

for iImagingFolder = 1:length(valid_raw_fNames)
    fimagingname = fullfile(raw_image_folder,valid_raw_fNames{iImagingFolder});
    cd(fimagingname)
    d=dir(fimagingname);

    ii = 1;
    errormatrix = {}; % If the copying doesn't work the error will keep them
    for i=3:length(d)
        if d(i).isdir
            if d(i).name(1) == 'T' % Finding T series
                dNumber = str2num(d(i).name(end-1:end)); % Number of the T series
                mkdir(fimagingname, ['TSeries ' num2str(dNumber)]) % making folder to copy this
                cd([fimagingname filesep 'TSeries ' num2str(dNumber)])
                mkdir(d(i).name)
                cd(fimagingname)
                try
                    movefile(d(i).name, [fimagingname filesep 'TSeries ' num2str(dNumber)])
                catch
                    errormatrix{ii} = d(i).name ;
                    ii = ii+1 ; 
                    continue
                end
                cd(fimagingname)

            else
                continue
            end
        end
    end
    if isempty(errormatrix)
        fprintf(sprintf('%s: Imaging folders generated succesfully...\n',valid_raw_fNames{iImagingFolder}))
    else
        for i = 1:length(errormatrix)
            warning('--- Problem with sorting ---')
            disp(['Couldn''t sort the folders: ' errormatrix{i}])
        end
    end
end


end