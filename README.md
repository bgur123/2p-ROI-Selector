# GUI for ROI selection - Under development by Burak Gür
This is a Graphical User Interface (GUI) for selecting Regions of Interest (ROI) within the 2-photon images. 

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

## Current Problems about GUI

1) After accidentally clicking adding new ROIs, exiting without any selection is not possible
2)