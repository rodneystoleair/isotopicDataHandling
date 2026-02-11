## How to use the script that hanles messy Elementar-type EA-IRMS data

Contributor: Rodion Andreev

1. Create new folders in "EA", "IRMS" and, if nesessary, in "agedepth" folders

2. Folder names should be identical. Further, your folder name will be an object
name

3. Load EA .csv files into "EA/%your_object_name%" folder. You can load multiple
.csv files that correspond to single EA batch. If you have age/depth data, load
it into "data/agedepth" folder. It should have .xlsx dimension and contain
column column "Name" with your sample IDs. Column "depth" is also nesessary

4. Open isotopicDataHandling.Rproj file. Then open data_handling.R script

5. Load/install dependencies (RStudio can suggest you to install packages you 
do not have)

6. Run the code with Shift + Ctrl + Enter

7. Script will ask you the object name. Write it, remembering that it should be
identical to new folder names

8. Script will also ask if age-depth data is present. Write "Y" is yes

9. Result: isotope data will be saved into "output" directory

10. You can plot the data with plotting.R script. Just open and run it with 
Shift + Ctrl + Enter
