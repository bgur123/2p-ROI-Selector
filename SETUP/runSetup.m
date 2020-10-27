

setupMessage = {'Welcome to the 2p-ROI-Selector setup' 'You will now select folders for determining path, data and pData'...
    'Press OK to continue'};

msgbox(setupMessage, '2p ROI Selector GUI Setup')
pause(5)
curDir = pwd;

msgbox('Please select your folder containing the GUI')
pause(2)
pathName = uigetdir(curDir,'Select the folder containing GUI');

msgbox('Select folder containing your raw data for later ROI selection')
pause(2)
data_folder = uigetdir(curDir,'Select folder containing your raw data for later ROI selection');

msgbox('Select folder containing (will contain) your processed data')
pause(2)
Pdata_folder = uigetdir(curDir,'Select folder containing (will contain) your processed data');

savePath = fullfile(pathName,'UserFolders.mat');
save(savePath,'pathName','data_folder','Pdata_folder');