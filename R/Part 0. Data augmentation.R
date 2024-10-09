library(tuneR)
library(seewave)
library(stringr)

# Create augmented sound files --------------------------------------------
# NOTE: Replace Jahoo with Danum to create Danum files
JahooTrainFiles <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/JahooClipsSorted_AugmentedNoise/train/Gibbons/',
           full.names = TRUE)

OutputDir <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/JahooClipsSorted_AugmentedNoise/train/Gibbons/'

for(a in 1:length(JahooTrainFiles)){
print(paste(a,'out of',length(JahooTrainFiles)))
TempWav <- readWave(JahooTrainFiles[a])

NoiseWav <- noise(kind = c("white"),duration = length(TempWav@left),samp.rate =TempWav@samp.rate)

CombinedWav1 <- TempWav 

CombinedWav1@left <- TempWav@left + (NoiseWav@left* sample(500:1000,1))
CombinedWav1 <- normalize(CombinedWav1, unit = "16")

writeWave(CombinedWav1, paste(OutputDir, "aug1_",basename(JahooTrainFiles[a]), sep=''  ) )

NoiseWav <- noise(kind = c("pink"),duration = length(TempWav@left),samp.rate =TempWav@samp.rate)

CombinedWav2 <- TempWav 

CombinedWav2@left <- TempWav@left + (NoiseWav@left* sample(500:1000,1))
CombinedWav2 <- normalize(CombinedWav2, unit = "16")

writeWave(CombinedWav2, paste(OutputDir, "aug2_",basename(JahooTrainFiles[a]), sep=''  ) )

}

OutputDir <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/JahooClipsSorted_AugmentedCropping/train/Gibbons/'

for (a in 1:length(JahooTrainFiles)) {
  print(paste(a, 'out of', length(JahooTrainFiles)))
  TempWav <- readWave(JahooTrainFiles[a])
  
  for (i in 1:2) {  # Create two cropped files per input
    
    # Choose a random crop length in seconds
    crop_length_sec <- sample(seq(1, 5, by = 0.1), 1)
    crop_length <- crop_length_sec * TempWav@samp.rate  # convert crop length to samples
    
    # Ensure the crop length does not exceed the audio length
    if (length(TempWav@left) > crop_length) {
      
      # Choose a random start point for the crop
      start_point <- sample(1:(length(TempWav@left) - crop_length), 1)
      end_point <- start_point + crop_length - 1
      
      # Crop the audio
      CroppedWav <- TempWav
      CroppedWav@left <- TempWav@left[start_point:end_point]
      
      # Normalize cropped audio
      CroppedWav <- normalize(CroppedWav, unit = "16")
      
      # Save the cropped audio with a new name, include the crop number in the filename
      writeWave(CroppedWav, paste(OutputDir, "cropped_", i, "_", basename(JahooTrainFiles[a]), sep=''))
      
    } else {
      print(paste("Skipping file", JahooTrainFiles[a], "because it is too short for cropping."))
    }
  }
}


# Create spectrogram images -----------------------------------------------

SoundFiles <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/JahooClipsSorted_AugmentedNoise',
                              full.names = TRUE,recursive = T)

OutputDir <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/images/'

for(y in 1:length(SoundFiles)){
  
  SoundFilePath <- SoundFiles[y]
  SoundFilesShort <- basename(SoundFilePath)
  DirName <- str_split_fixed(SoundFilePath,pattern = 'DataAugmentation/',n=2)[,2]
  DirNameShort <- str_split_fixed(DirName,pattern = '/',n=2)[,1]
  UpdatedDirName <- paste(DirNameShort, str_split_fixed(DirName,pattern = '/',n=3)[,2],'/',sep='/')
  
  Folder <- str_split_fixed(DirName,pattern = '/',n=4)[,3]
  
  subset.directory <- paste(OutputDir,UpdatedDirName,Folder,sep='')
  
  if (!dir.exists(subset.directory)){
    dir.create(subset.directory,recursive = T)
    print(paste('Created output dir',subset.directory))
  } else {
    print(paste(subset.directory,'already exists'))
  }
  
  

  wav.rm <- str_split_fixed(SoundFilesShort,pattern='.wav',n=2)[,1]
  jpeg(paste(subset.directory, '/', wav.rm,'.jpg',sep=''),res = 50)
  temp.name <- SoundFiles[y]
  short.wav <-readWave(temp.name)
  #short.wav <- downsample(short.wav, 16000)
  seewave::spectro(short.wav,tlab='',flab='',axisX=F,axisY = F,flim=c(0.4,3),scale=F,grid=F,noisereduction=1)
  graphics.off()
  
}


# Create spectrogram images test data -----------------------------------------------

SoundFiles <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/ClipsManual/',
                         full.names = TRUE,recursive = T)

OutputDir <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/data/testimages/images_jahoo_WA/test/'

for(y in 1:length(SoundFiles)){
  
  SoundFilePath <- SoundFiles[y]
  SoundFilesShort <- basename(SoundFilePath)
  DirName <- str_split_fixed(SoundFilePath,pattern = 'ClipsManual/',n=2)[,2]
  # DirNameShort <- str_split_fixed(DirName,pattern = '/',n=2)[,1]
  # UpdatedDirName <- paste(DirNameShort, str_split_fixed(DirName,pattern = '/',n=3)[,2],'/',sep='/')
  # 
  Folder <- str_split_fixed(DirName,pattern = '/',n=3)[,2]
  
  subset.directory <- paste(OutputDir,Folder,sep='')
  
  if (!dir.exists(subset.directory)){
    dir.create(subset.directory,recursive = T)
    print(paste('Created output dir',subset.directory))
  } else {
    print(paste(subset.directory,'already exists'))
  }
  
  
  
  wav.rm <- str_split_fixed(SoundFilesShort,pattern='.wav',n=2)[,1]
  jpeg(paste(subset.directory, '/', wav.rm,'.jpg',sep=''),res = 50)
  temp.name <- SoundFiles[y]
  short.wav <-readWave(temp.name)
  #short.wav <- downsample(short.wav, 16000)
  seewave::spectro(short.wav,tlab='',flab='',axisX=F,axisY = F,flim=c(0.4,3),scale=F,grid=F,noisereduction=1)
  graphics.off()
  
}
