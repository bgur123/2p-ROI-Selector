function save_processed_data_1ch_BG_GUI(in)


fileloc = in.fileloc;

[~, imageNum] = fileparts(in.fileloc);
currPath = fullfile(handles.foldername,imageNum);
cd(currPath);


strct=in;
if(isfield(in,'ch1'))
    strct = rmfield(strct,'ch1');
    strct = rmfield(strct,'ch1a');    
    strct = rmfield(strct,'ch1b');
%     strct = rmfield(strct,'ch2');
%     strct = rmfield(strct,'ch2a');
end

pathroot=in.fileloc;
f=find((pathroot == '\') + (pathroot == '/'));
f=f(end);
pathroot = pathroot((f+1):end); 
flyroot = in.dataID;
save([flyroot '_' pathroot '_pData.mat'],'strct');

cd(curDir);