function ROI_auto2(timeSeries, expectedROINumber)

%% Set parameters
sizY = size(timeSeries);                  % size of data matrix
patch_size = [445,582];                   % size of each patch along each dimension (optional, default: [32,32])
overlap = [32,32];                        % amount of overlap in each dimension (optional, default: [4,4])

patches = construct_patches(sizY(1:end-1),patch_size,overlap);
K = 10;                                            % number of components to be found
tau = 16;                                          % std of gaussian kernel (size of neuron) 
p = 0;                                            % order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
merge_thr = 0.8;                                  % merging threshold

options = CNMFSetParms(...
    'd1',sizY(1),'d2',sizY(2),...
    'search_method','dilate','dist',3,...      % search locations when updating spatial components
    'deconv_method','constrained_foopsi',...    % activity deconvolution method
    'temporal_iter',2,...                       % number of block-coordinate descent steps 
    'init_method','HALS',...
    'cluster_pixels',false,...
    'ssub',2,...
    'tsub',1,...
    'fudge_factor',0.98,...                     % bias correction for AR coefficients
    'merge_thr',merge_thr,...                   % merging threshold
    'gSig',tau,... 
    'spatial_method','regularized'...
    );

%% Run on patches

[A,b,C,f,S,P,RESULTS,YrA] = run_CNMF_patches(timeSeries,K,patches,tau,p,options);

%% classify components
[ROIvars.rval_space,ROIvars.rval_time,ROIvars.max_pr,ROIvars.sizeA,keep] = classify_components(Y,A,C,b,f,YrA,options);

%% run GUI for modifying component selection (optional, close twice to save values)
Cn = reshape(P.sn,sizY(1),sizY(2));  % background image for plotting
run_GUI = false;
if run_GUI
    Coor = plot_contours(A,Cn,options,1); close;
    GUIout = ROI_GUI(A,options,Cn,Coor,keep,ROIvars);   
    options = GUIout{2};
    keep = GUIout{3};    
end

%% re-estimate temporal components

A_keep = A(:,keep);
C_keep = C(keep,:);
options.p = 2;      % perform deconvolution
[C2,f2,P2,S2,YrA2] = update_temporal_components_fast(data,A_keep,b,C_keep,f,P,options);

%% plot results
options.sx = 64;
plot_components_GUI(double(Y),A,C,b,f,Cn,options);