function imageData = ROI_Selector(folder_name,imageNumber)

if nargin == 1
    warning('Image number or folder location is not selected...')
    warning('Please select the image number and folder')
    return
end




file = fullfile(folder_name,['Image ' num2str(imageNumber)])
disp(file);

try
    
    cd(file)
catch error
    errordlg(error.message)
    return
    
end


m = dir('data_file*');

imageData = load('data_file');
   
