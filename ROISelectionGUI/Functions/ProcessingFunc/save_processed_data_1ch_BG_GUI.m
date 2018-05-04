function save_processed_data_1ch_BG_GUI(in, handles)


fileloc = in.fileloc;

[~, imageNum] = fileparts(in.fileloc);
currPath = fullfile(handles.foldername,imageNum);
cd(currPath);


strct=in;

% Removing some unused variables for later
if(isfield(in,'ch1'))
    
    % Removing unused parameters
    strct = rmfield(strct,'ch1');
    strct = rmfield(strct,'ch1a');    
    strct = rmfield(strct,'ch1b');
    
    % Removing the image series of baseline (not masks)
    if (isfield(in,'BaseLine'))
        strct = rmfield(strct,'BaseLine');
    end
    
    % Removing the 2nd channel (normally Green channel is 2nd but in the
    % GUI it is switched so it becomes ch1 that's why now ch2 which is the
    % red channel is removed)
    if(isfield(in,'ch2'))
        warning('Removing channel 2 variables and baseline series')
        strct = rmfield(strct,'ch2');
        strct = rmfield(strct,'ch2a');
        strct = rmfield(strct,'ch2b');
        strct = rmfield(strct,'ch2BaseLine');
        strct = rmfield(strct,'ch1BaseLine');
    end
    

end

pathroot=in.fileloc;
f=find((pathroot == '\') + (pathroot == '/'));
f=f(end);
pathroot = pathroot((f+1):end); 
flyroot = in.dataID;
save([flyroot '_' pathroot '_pData.mat'],'strct');

cd(currPath);