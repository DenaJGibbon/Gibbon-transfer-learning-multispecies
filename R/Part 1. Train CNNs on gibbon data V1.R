# Load libraries -------------------------------------------------------------------------
library(dplyr)
library(flextable)
library(dplyr)
library(gibbonNetR)

# Grey Gibbon Binary Model Training ---------------------------------------

TrainingFolders <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/images/Danum Images/',
                              full.name=T)

# Location of spectrogram images for testing
test.data.path <-'/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/data/training_images_sorted/Danum/test/'

output.dir <-'/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/modelruns_earlystoponly/'

# Number of epochs to include
epoch.iterations <- c(20)

# Train the models specifying different architectures
architectures <- c( 'resnet18', 'resnet50', 'resnet152','alexnet', 'vgg16','vgg19')
freeze.param <- c(TRUE, FALSE)

for(d in 1:3){
for (a in 1:length(architectures)) {
  for (b in 1:length(freeze.param)) {
    for(c in 1:length(TrainingFolders)){

      input.data.path <-  TrainingFolders[c]
      
      trainingfolder.short <-  basename(TrainingFolders[c])
    
      gibbonNetR::train_CNN_binary(
      input.data.path = input.data.path,
      noise.weight = 0.25,
      architecture = architectures[a],
      save.model = FALSE,
      learning_rate = 0.001,
      test.data = test.data.path,
      batch_size = 64,
      unfreeze.param = freeze.param[b],
      # FALSE means the features are frozen
      epoch.iterations = epoch.iterations,
      list.thresholds = seq(0, 1, .1),
      early.stop = "yes",
      output.base.path = paste(output.dir,trainingfolder.short,'_',d,sep=''),
      trainingfolder = trainingfolder.short,
      positive.class = "Gibbons",
      negative.class = "Noise"
    )
    
  }
}
}
}
