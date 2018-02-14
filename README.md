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

