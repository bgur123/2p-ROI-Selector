function collect_pdata_mac_BG_GUI(data_folder, pData_dir)



disp('--------Pick the source folder for pData files--------')
[fname]=uigetdir(data_folder,'Pick the source folder for pData files');
d=dir(fname);

disp('Source folder:')
disp([fname])

% pData_dir = '/Users/burakgur/2p/2-Burak_pData';
disp('Target folder:')
disp(pData_dir)
%ms: structure with LDM (((/ fly folders)))

% num=0;
for i=3:length(d)% Not sure but in windows you might be starting in a different index
    if d(i).isdir
        cd([fname '/' d(i).name]);  %ms: z.B. .../110601m_fly1/LDM...
%         ind = strfind(fname,'/');
%         flyID = fname(ind(end)+1:end); %finds the flyID (e.g. 110601m_fly1) in the string
        e = dir('*_pData.mat');
        if(~isempty(e))
            copyfile(e.name,pData_dir);
        end
        cd ..
    end
end

disp('--------Operation Successful--------')
