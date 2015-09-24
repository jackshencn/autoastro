library(tiff)
library(FITSio)
setwd(dir= "E:/Astronomy Testing/Advanced calibration/")

########
# This pipeline use optical black dark current to normalize the calibration
# Convert all NEF file into TIFF with unprocessed_raw -T *.NEF from libraw
# Change zone definition accordingly (Dummy columns, dark columns, active pixels, etc)
########


#Read in Master Bias
master_bias = readFITS(file="Bias.fits")
#Offset 8,74 to non-overscan
master_bias_offset = master_bias$imDat[9:(9+4992-1),75:(75+3280-1)]
rm(master_bias)
master_offset = mean(master_bias_offset[4955:4982,])

Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

###########
# Do Dark Frame First
###########

#Import dark frames
nef_list = list.files(path="./Dark/",pattern="*.tiff",full.names=TRUE)
ob_ave = array(0,dim=length(nef_list))
bias_ave = array(0,dim=length(nef_list))
dark_frame = array(0,dim=c(length(nef_list),4992,3280))
for (i in 1:length(nef_list)){
  dark_buffer = t(readTIFF(nef_list[i],as.is=TRUE))
  bias_ave[i] = mean(dark_buffer[4955:4982,])
  #Subtract master bias and bias to 0
  dark_frame[i,,] = dark_buffer - master_bias_offset - (bias_ave[i]- master_offset)
  ob_ave[i] = mean(dark_frame[i,4951:4952,])
}

#Normalize dark current
ave_dark_count = mean(ob_ave)
for (i in 1:length(nef_list)){
  dark_frame[i,,] = dark_frame[i,,] *ave_dark_count/ob_ave[i]
}

#Create master dark
master_dark= matrix(0, 4992,3280)
for (x in 1:4992){
  for (y in 1:3280){
    master_dark[x,y] = median(dark_frame[,x,y])
  }
}
rm(dark_frame)
rm(dark_buffer)
writeFITSim(master_dark,"Master_dark.fits",type="single")

master_dark = readFITS("Master_dark.fits")$imDat
ave_dark_count = mean(master_dark[4951:4952,])

###########
# Now Flat Frame
###########


#Flat Frame
nef_list = list.files(path="./Flat/",pattern="*.tiff",full.names=TRUE)
bias_ave = array(0,length(nef_list))
max_level = array(0,dim=c(length(nef_list),4))
flat_frame = array(0,dim=c(length(nef_list),4992,3280))
for (i in 1:length(nef_list)){
  flat_buffer = t(readTIFF(nef_list[i],as.is=TRUE))
  bias_ave[i] = mean(flat_buffer[4955:4982,])
  #Subtract master bias and bias to 0
  flat_buffer = flat_buffer - master_bias_offset - (bias_ave[i]- master_offset)
  flat_frame[i,,] = flat_buffer
  for (y in 1:2){
    for (x in 1:2){
      center_128 = flat_buffer[seq(2368+x,2624,2),seq(1512+y,1768,2)]
      max_level[i,x+(y-1)*2] = mean(center_128)
    }
  }
}
rm(flat_buffer)
rm(center_128)

#Plot max graph
plot(max_level[,1])
plot(max_level[,2])
plot(max_level[,3])
plot(max_level[,4])

#Normalize dark current
ave_max_intensity = mean(max_level[,2])
for (i in 1:length(nef_list)){
  flat_frame[i,,] = flat_frame[i,,] *ave_max_intensity/max_level[i,2]
}

#Now Creat Master Flat
master_flat= matrix(0, 4992,3280)
for (x in 1:4992){
  for (y in 1:3280){
    master_flat[x,y] = mean(flat_frame[,x,y])
  }
}
rm(flat_frame)

#Save file
writeFITSim(master_flat,"Master_flat.fits",type="single")

#Read in again for calibration
master_flat = readFITS("Master_flat.fits")$imDat
red_center = mean(master_flat[seq(2368+1,2624,2),seq(1512+1,1768,2)])
green_center = mean(master_flat[seq(2368+2,2624,2),seq(1512+1,1768,2)])
blue_center = mean(master_flat[seq(2368+2,2624,2),seq(1512+2,1768,2)])

for (x in 1:4992){
  for (y in 1:3280){
    if ((x + y) %% 2 == 1){
      #Green Pixels
      master_flat[x,y] = green_center / master_flat[x,y]
    } else {
      if (x %% 2 == 1){
        #red pixels
        master_flat[x,y] = red_center / master_flat[x,y]
      } else{
        #blue pixels
        master_flat[x,y] = blue_center / master_flat[x,y]
      }
    }
    if (x >= 4949) {master_flat[x,y] = 1}
  }
}

###########
# Now calibrate Light Frame
###########

#Calibrate light frame
nef_list = list.files(path="./Cygnus 180/",pattern="*.tiff",full.names=TRUE)
mode_before = array(0,length(nef_list))
mode_after = array(0,length(nef_list))
mean_dark = array(0,length(nef_list))

for (i in 1:length(nef_list)){
  #Load Image and rotate
  light_buffer = t(readTIFF(nef_list[i],as.is=TRUE))
  mode_before[i] = Mode(light_buffer[seq(2,4948,2),seq(1,3280,2)])
  
  #Subtract normalized bias
  offset_level = mean(light_buffer[4955:4982,])
  #mode_dark[i] = Mode(light_buffer[4951:4952,])
  #subtract bias level
  light_buffer = light_buffer - master_bias_offset - (offset_level - master_offset)
  
  #Get average dark count 
  dark_count = mean(light_buffer[4951:4952,])
  mean_dark[i] = dark_count
  #Subtract master dark
  light_buffer = light_buffer - master_dark * (dark_count/ave_dark_count)
  mode_after[i] = Mode(round(light_buffer[seq(2,4948,2),seq(1,3280,2)]))
  
  #Flat Correction
  light_buffer = light_buffer * master_flat
  
  #light_buffer = light_buffer + 128
  
  #Optional Crop optical black
  light_buffer = light_buffer[1:4948,]
  
  #Output to FITS
  writeFITSim(light_buffer,gsub('.tiff','_cal.fits',nef_list[i],),"single")
}
