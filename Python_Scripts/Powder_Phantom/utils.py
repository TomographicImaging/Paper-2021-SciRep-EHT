import os
import wget
import numpy as np

# Function for downloading data files from Zenodo
def download_zenodo():
   
   if os.path.exists("MatlabData"):
       pass
   else:
       print("Downloading files from Zenodo ... ")
       os.mkdir("MatlabData")
       # Powder Phantom Data
       wget.download("https://zenodo.org/record/5825464/files/Powder_phantom_180s_180Proj_sinogram.mat", out="MatlabData")
       wget.download("https://zenodo.org/record/5825464/files/Powder_phantom_30s_30Proj_sinogram.mat", out="MatlabData")
       wget.download("https://zenodo.org/record/5825464/files/Energy_axis.mat", out="MatlabData")
       print("\nFinished.")      
    
def rmse_sing_chan(calculated,truth,errors):
    # Calculates RMSE for every channel of a single voxel
    for i in range(0,len(calculated)):
        errors[i] = np.sqrt(np.mean((calculated[i] - truth[i]) ** 2))
    print('Calculation Complete!') 
    return errors

def cnr_spatial(mean_signal,std_signal,mean_bg,std_bg):
    # Need an ROI to do this
    ratio = (np.abs(mean_signal-mean_bg))/(std_signal+std_bg)
    print('Calculation Complete!')
    return ratio