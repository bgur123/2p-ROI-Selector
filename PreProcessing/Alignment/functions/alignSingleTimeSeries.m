function alignSingleTimeSeries(series_path, wantMovie, alignment, referenceFrameNum)
    
    %% Check folder names etc.
    % The imaging series folders have to have string: 'Series' within them
    % for example: T Series 1, T-Series 1 
    
    cd(series_path)
    out.fileloc = series_path;
    series_contents = struct2cell(dir(series_path)); 
    series_content_n = series_contents(1,:);
    imageID = series_content_n(contains(series_content_n,'Series') ...
        & ~contains(series_content_n,'.mat'));
    imageID = imageID{1};
    images_path = fullfile(series_path,imageID);
    [~,seriesID]=fileparts(series_path);
    [~, flyID,~] = fileparts(fileparts(series_path)); 
    out.expID = flyID;
    out.imageID = sprintf('%s_%s',flyID,seriesID)
    
    %% Information of time series.
    % This is extracted from an .xml file located in the T series folder
    % Generated automatically by the imaging software
    xml_file = dir(fullfile(images_path,'*.xml'));
    xml_file_name = xml_file.name;
    cd(images_path)
    [imaging_info, scan_info] = getXmlInfo(xml_file_name);

    nImages = numel(imaging_info.stimulusFrames); % Number of frames.
    imageDepth = str2double(scan_info.bitDepth);% Bit depth.
    height = str2double(scan_info.linesPerFrame);% lines per frame.
    width = str2double(scan_info.pixelsPerLine);% pixels per line.

    %% Define output file.
    % Remove extension from filename.
    nameNoExt = regexp(xml_file_name, ['.' 'xml'], 'split');
    
    
    % Save time stamps.
    timeStampsFile = [nameNoExt{1} '_times.mat'];
    % Extract the time stamps.
    stimulusFrames = [imaging_info.stimulusFrames{:}];
    % Compute mean frame duration from relative frame times. 
    relativeFrameTimes = {stimulusFrames(:).relativeTime};
    relativeFrameTimes = str2double(relativeFrameTimes');
    relFrameLength = mean(diff(relativeFrameTimes));
    % Compute mean frame duration from absolut frame times. 
    absoluteFrameTimes = {stimulusFrames(:).absoluteTime};
    absoluteFrameTimes = str2double(absoluteFrameTimes');
    absFrameLength = mean(diff(absoluteFrameTimes));
    % Frame duration from microscope settings.
    framePeriod = str2double(scan_info.framePeriod);
    % Time stamps, relative or absolute?.
    ts = relativeFrameTimes;
    % ts = imagingInfo.TimeStamps.TimeStamps;
    save(timeStampsFile, 'ts');
    % fr = mean(diff(ts));

    %% Perform alignment.
    % Read time series
    imageArray = readTwoPhotonTimeSeries(xml_file_name, imaging_info,1);
    
    % Create reference stack
    refStack = zeros(height, width, referenceFrameNum); 
    for iFrame = 1: referenceFrameNum 
        refStack(:, :, iFrame) = imageArray(:, :, iFrame);
    end
    % Maximum intensity projection of reference stack.
    refFrame = max(refStack, [], 3);
    %% Perform alignment based on maximizing image crosscorrelation in the Fourier space.
    
    if alignment
        % Create filename for aligned images, with TIFF format.
        alignedFile = [nameNoExt{1}, '_aligned.tif'];

        [out1, out2, out3] = fourierCrossCorrelAlignment(imageArray,...
            refFrame, 'xml', alignedFile);
        
        registeredImages = out1(:,:,1:nImages);
        unregisteredImages = out2(:,:,1:nImages);
        medianFilteredImages = out3(:,:,1:nImages);
   

        % Store unaligned image in output.
        out.images_raw = im2double(unregisteredImages);
        % Store aligned image in output.
        out.images_aligned = im2double(registeredImages);
        out.alignment = 1;
    else
        out1 = uint16(imageArray);
        notalignedImages = out1(:,:,1:nImages);
        % Store notaligned image in output.
        out.images_raw = im2double(notalignedImages);
        out.alignment = 0;

    end
        

    %% Write to out.xml the info in scanInfo struct.
    out.xml = scan_info;
    out.xml.frames = nImages;
    % Rename frametime, frame rate, and z depth for subsequent scripts.
    out.xml.frametime = framePeriod;
    out.xml.framerate = 1/framePeriod; 
    try
        out.xml.zdepth = str2double(scanInfo.positionCurrent.Z); 
    catch
        out.xml.zdepth = str2double(scan_info.positionCurrent.ZAxis); %after z piezo installation
    end
    
    %store absoluteFrameTimes for use in later analysis
    out.xml.absoluteFrameTimes = absoluteFrameTimes;
    
    %store relativeFrameTimes for use in later analysis
    out.xml.relativeFrameTimes = relativeFrameTimes;

    %% Process stimulus file.
    stim_dir = dir(fullfile(series_path,'stimulus_output*'));
    stim_info = load(fullfile(series_path,stim_dir.name));
    stim_info = stim_info.outputObj;
    frame_nums = stim_info.imaging_frame; 
    stim_type = stim_info.meta.stim_name;
    out.stimTimes = stim_info.sample_time; 
    stimulus_epoch = stim_info.stimulus_epoch;
    
    nValidStimFrames = nImages; %How many total frames actually imaged
    
    % Find average value of stimulus for each imaging frame.
    avrstimval = zeros(nValidStimFrames,1); 
    fstimval = zeros(nValidStimFrames,1);
    
    fstim_info1 = zeros(nValidStimFrames,1);
    fstim_info2 = zeros(nValidStimFrames,1);
    fstim_info3 = zeros(nValidStimFrames,1);
    

    
    firstEntry = frame_nums(1);
     
    for k = firstEntry:nValidStimFrames
        inds = find(frame_nums == k);
        if k == 0
            continue
        end
        if(~isempty(inds))
            stimval = stim_info.stimulus_epoch(inds);
            avrstimval(k) = mean(stimval);
            fstimval(k) = stimval(1);
            
            stim_info1 = stim_info.stim_info1(inds);
            stim_info2 = stim_info.stim_info2(inds);
            stim_info3 = stim_info.stim_info3(inds);
            
            fstim_info1(k) = stim_info1(1);
            fstim_info2(k) = stim_info2(1);
            fstim_info3(k) = stim_info3(1);
            
            
            
            last_k_withStimEntries = k;
            
        %if scanning is faster than stimulus, use stimulus info of previous
        %frame that was written (last_k_withStimEntries):
        elseif(isempty(inds)) 
            inds = find(frame_nums == last_k_withStimEntries); 
            stimval = stim_info.stimulus_epoch(inds);
            avrstimval(k) = mean(stimval);
            fstimval(k) = stimval(1);
            
            stim_info1 = stim_info.stim_info1(inds,:);
            stim_info2 = stim_info.stim_info2(inds,:);
            stim_info3 = stim_info.stim_info3(inds,:);
            
            fstim_info1(k) = stim_info1(1,:);
            fstim_info2(k) = stim_info2(1);
            fstim_info3(k) = stim_info3(1);
            
        end
    end
    
    for k = 1:firstEntry-1
            avrstimval(k) = avrstimval(firstEntry);
            fstimval(k) = fstimval(firstEntry);
            
            fstim_info1(k) = fstim_info1(firstEntry);
            fstim_info2(k) = fstim_info1(firstEntry);
            fstim_info3(k) = fstim_info1(firstEntry);
            
    end
    

    

    out.stimulus_epoch = stimulus_epoch;
    out.avrstimval = avrstimval;
    out.fstimval = fstimval;
    out.frame_nums = frame_nums;
    out.stim_type = stim_type;
    out.fstim_info1 = fstim_info1;
    out.fstim_info2 = fstim_info2;
    out.fstim_info3 = fstim_info3;
    
    out.stim_info1 = stim_info.stim_info1;
    out.stim_info2 = stim_info.stim_info2;
    out.stim_info3 = stim_info.stim_info3;
    
    cd(series_path)
    save('aligned_data', 'out', '-v7.3'); %save big files as well
    save('stim', 'stimulus_epoch', 'avrstimval', 'fstimval', 'frame_nums', ...
         'stim_type', 'fstim_info1', 'fstim_info2', 'fstim_info3');

    %% Make movie for Bruker images.
    if wantMovie
        % Raw data movie.
%         makeTimeSeriesMovie(imageArray, 'original_series', 'mp4');
        % Aligned unfiltered data movie.
        if alignment
            makeTimeSeriesMovie(registeredImages, ...
                            'aligned_unfiltered_series_16bit', 'mp4');
        % Aligned median-filtered data movie.
%         makeTimeSeriesMovie(medianFilteredImages, ...
%                             'aligned_medianFiltered_series', 'mp4');
        else
            makeTimeSeriesMovie(notalignedImages, ...
                            'notaligned_unfiltered_series_16bit', 'mp4');
        end
            
    end
end
