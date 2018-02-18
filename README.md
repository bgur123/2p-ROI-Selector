# GUI for ROI selection ## Under development by Burak Gür
This is a Graphical User Interface (GUI) for selecting Regions of Interest (ROI) within the 2-photon images. 

# Includes a setup function for storing necessary folder paths
setupGUI.m

# All needed functions are included in the folder

# The script started in Summer 2017 and its functions include:
-Manual selection of ROIs
-Manual or automatic numbering of ROIs
-Manual numbering of layers based on visual inspection

-Transferring ROI masks from one image to another image within same fly dataset
-Options include:
	- Moving the mask
	- Modifying or deleting existing ROIs
	- Adding new ROIs

-View of previously selected ROIs simultaneously while selecting a new set of ROIs
-Plotting ROI intensity signals along with stimulus
-Saving data in the Silies lab commonly used format pData
-Transferring the saved pData to a master folder

## Current Problems about GUI ##

1) Figure colouring can cause problems in different matlab versions. Make a logical figure colouring especially when the masks are being plotted and the colormaps are being generated. --SOLVED??--

2) Auto numerate when using different ROI numbers than previous masks

3) During setup a function should be added to understand the data naming structure of the user

4) Selection of ROI selection method should be more logical (clicking one and unclicking one etc.) since it can lead to problems when the last action was to unclick one 

5) While applying a mask from a previous image it can only apply mask1 so this should also be flexible