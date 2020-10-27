# 2p-ROI-Selector 
This is a Graphical User Interface (GUI) for selecting Regions of Interest (ROI) and extracting their signals from the two-photon time series images. 

## Includes a setup function for storing necessary folder paths
setupGUI.m

## Functions include:
-Manual selection of ROIs

-Manual or automatic numbering of ROIs

-Manual numbering of layers based on visual inspection
	-Can be done in GUI integrated or external figures
-Manual assignment of groups for ROIs
	-Layer numbers (M1 etc.) and cell types(L2-L3) can be labeled. 
-Transferring ROI masks from one image to another image within same fly dataset
-Options include:
	- Moving the mask 
	- Modifying or deleting existing ROIs (Modify -> right click on ROI | Delete -> 		right click)
	- Adding new ROIs

-View of previously selected ROIs simultaneously while selecting a new set of ROIs

-Plotting ROI intensity signals along with stimulus

-Saving data in the Silies lab commonly used format pData

-Transferring the saved pData to a master folder

## Pre-processing of data
In order to use this GUI, the data should be pre-processed in a certain manner. These scripts are included in the "pre_processing"" folder.

First run the folder processing and then the alignment steps.

## Current Problems about GUI

No problem registered.
