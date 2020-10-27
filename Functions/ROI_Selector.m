function [imageData, file] = ROI_Selector(folder_name,imageNumber)

% Checking inputs
if nargin == 1
    warndlg('Image number or folder location is not selected. Please select the image number and folder')
    return
end


% Locating the desired image path
folder_contents = dir(folder_name);

for iFolder = 1:length(folder_contents)
    curr_folder_name = folder_contents(iFolder).name;
    
    % Checking the image number
    curr_image_num = regexp(curr_folder_name,'\d*','Match');
    if ~isempty(curr_image_num)
        curr_image_num = str2num(curr_image_num{1});
    
        if curr_image_num == imageNumber
            target_image_folder_name = curr_folder_name;
            break
        else
            continue
        end
    else
        continue
    end
end
    
% Loading the desired image path
file = fullfile(folder_name,target_image_folder_name);
disp(file);

try
    
    cd(file)
catch error
    errordlg(error.message)
    return
    
end


imageData = load('aligned_data');


    
