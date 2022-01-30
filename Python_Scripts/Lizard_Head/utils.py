import os
import wget
import numpy as np

def download_zenodo():
   
   if os.path.exists("MatlabData"):
       pass
   else:
       print("Downloading files from Zenodo ... ")
       os.mkdir("MatlabData")
       # Lizard Head Data
       wget.download("https://zenodo.org/record/5826212/files/lizard_180Proj_Supp_1_180.mat", out="MatlabData")
       wget.download("https://zenodo.org/record/5826212/files/Energy_axis.mat", out="MatlabData")
       print("\nFinished.")      
        
def cnr_spatial(mean_signal,std_signal,mean_bg,std_bg):
    # Need an ROI to do this
    ratio = (np.abs(mean_signal-mean_bg))/(std_signal+std_bg)
    print('Calculation Complete!')
    return ratio

def K_edge_sub(rec, edge_channel, sep, width):
    # Take images above and below absorption edge, then subtract them
    # Best to take images with a small range of channels, and some separation from edge itself
    # Recommended Separation = 2, Width = 5
    # Inputs: - rec, reconstructed data set (e.g. PDHG)
    #         - edge_channel, the channel number corresponding to where the edge lies (based on your calibration)
    # 	      - sep, channel separation distance from either side of the k-edge position
    # 	      - width, number of channels you want to take either side of k-edge
    # Outputs: - rec_EdgeSub, 3D array of subtracted data, containing data only due to k-edge element
    #	       - rec_rem_avg, remaining data, acquired by removing the subtracted data from the original dataset,
    #		averaged to give a 3D array of non-contrast enhanced data

    print('Edge at channel: ', edge_channel)
    channel_range_upper = np.arange(edge_channel+sep,edge_channel+sep+width+1)
    channel_range_lower = np.arange(edge_channel-sep-width,edge_channel-sep+1)
    print('Integrated channel ranges', channel_range_upper,channel_range_lower)
    rec_aboveEdge = np.mean(rec.as_array()[channel_range_upper,:,:,:],0)
    rec_belowEdge = np.mean(rec.as_array()[channel_range_lower,:,:,:],0)
    rec_EdgeSub = rec_aboveEdge-rec_belowEdge
    
    rec_rem = rec.as_array() - rec_EdgeSub
    rec_rem_avg = np.mean(rec_rem,0)
    print('Calculation Complete!')
    return [rec_EdgeSub, rec_rem_avg]