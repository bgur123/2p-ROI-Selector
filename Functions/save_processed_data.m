function save_processed_data(in, handles)


cd(handles.seriesPath);


data=in;

% Removing some unused variables for later
if(isfield(in,'images_aligned'))
    
    % Removing parameters that are not needed for future analysis
    data = rmfield(data,'images_aligned');
    data = rmfield(data,'images_raw');    
    
end

[rest,imageID] = fileparts(handles.seriesPath);
[~,flyID] = fileparts(rest);
flyroot = in.dataID;
save([flyID '_' imageID '_pData.mat'],'data');

cd(handles.seriesPath);