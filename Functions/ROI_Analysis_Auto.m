function out = ROI_Analysis_Auto(in,handles)
% Auto ROI selection function using https://github.com/epnev/ca_source_extraction
%% -------------- Auto ROI selection and saving --------------


out = ROI_auto1_2(in, handles.expectedROInumber, handles);