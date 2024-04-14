# Organize training, valid, and test split based on recorder ID
library(stringr)
set.seed(13)


GibbonsMalaysia1 <- list.files('data/trainingimages/imagesmalaysia/train/Gibbons',
                             full.names = T)

GibbonsMalaysia2 <- list.files('data/trainingimages/imagesmalaysia/valid/Gibbons',
                             full.names = T)

GibbonsMalaysia3 <- list.files('data/trainingimages/imagesmalaysia/test/Gibbons',
                             full.names = T)

GibbonsMalaysia <- c(GibbonsMalaysia1,GibbonsMalaysia2,GibbonsMalaysia3)

GibbonsMalaysiaSplit <- str_split_fixed(GibbonsMalaysia,pattern = '_',n=5)

GibbonsMalaysiaRecorder <- GibbonsMalaysiaSplit[,2]
GibbonsMalaysiaDate <- GibbonsMalaysiaSplit[,3]
GibbonsMalaysiaTime <- GibbonsMalaysiaSplit[,4]

GibbonsMalaysiaRecID <- paste(GibbonsMalaysiaRecorder,GibbonsMalaysiaDate,GibbonsMalaysiaTime,
                            sep='_')


train_idx_Gibbons <- which(GibbonsMalaysiaRecorder=="SW1"|
                           GibbonsMalaysiaRecorder=="SW10"|
                           GibbonsMalaysiaRecorder=="SW2"|
                           GibbonsMalaysiaRecorder=="SW4"|
                           GibbonsMalaysiaRecorder=="SW5"|
                           GibbonsMalaysiaRecorder=="SW6"|
                             GibbonsMalaysiaRecorder=="SW8")

valid_idx_Gibbons <- which(GibbonsMalaysiaRecorder=="SW7")

test_idx_Gibbons <-  which(GibbonsMalaysiaRecorder=="SW9")

FolderVec <- c('train','valid', 'test')

outputBasePath <- 'data/training_images_sorted/Danum'

GibbonsMalaysiaRecIDun <- unique(GibbonsMalaysiaRecID)

CombinedGibbons <- list(train_idx_Gibbons,valid_idx_Gibbons,test_idx_Gibbons)

for (y in 1:3) {
  
  # Determine the DataType based on the index
  if (y ==1 ) {
    DataType <- FolderVec[1]
  } else if (y ==2) {
    DataType <- FolderVec[2]
  } else {
    DataType <- FolderVec[3]
  }
  
  subset_directory <- file.path(outputBasePath, DataType, 'Gibbons/')
  
  if (!dir.exists(subset_directory)) {
    dir.create(subset_directory, recursive = TRUE)
    message('Created output dir: ', subset_directory)
  } else {
    message(subset_directory, ' already exists')
  }
  
  ImageIndices <-  unlist(CombinedGibbons[[y]])
  
  
  file.copy( GibbonsMalaysia[ImageIndices],
             paste(subset_directory,basename(GibbonsMalaysia[ImageIndices]),sep = '' ))
  
}



NoiseMalaysia1 <- list.files('data/trainingimages/imagesmalaysia/train/Noise',
                               full.names = T)

NoiseMalaysia2 <- list.files('data/trainingimages/imagesmalaysia/valid/Noise',
                               full.names = T)

NoiseMalaysia3 <- list.files('data/trainingimages/imagesmalaysia/test/Noise',
                               full.names = T)

NoiseMalaysia <- c(NoiseMalaysia1,NoiseMalaysia2,NoiseMalaysia3)

NoiseMalaysiaSplit <- str_split_fixed(NoiseMalaysia,pattern = '_',n=5)

NoiseMalaysiaRecorder <- NoiseMalaysiaSplit[,2]
NoiseMalaysiaDate <- NoiseMalaysiaSplit[,3]
NoiseMalaysiaTime <- NoiseMalaysiaSplit[,4]

NoiseMalaysiaRecID <- paste(NoiseMalaysiaRecorder,NoiseMalaysiaDate,NoiseMalaysiaTime,
                              sep='_')

train_idx_Noise <- which(NoiseMalaysiaRecorder=="SW1"|
                             NoiseMalaysiaRecorder=="SW10"|
                             NoiseMalaysiaRecorder=="SW2"|
                             NoiseMalaysiaRecorder=="SW4"|
                             NoiseMalaysiaRecorder=="SW5"|
                             NoiseMalaysiaRecorder=="SW6"|
                             NoiseMalaysiaRecorder=="SW8")

valid_idx_Noise <- which(NoiseMalaysiaRecorder=="SW7")

test_idx_Noise <-  which(NoiseMalaysiaRecorder=="SW9")

FolderVec <- c('train','valid', 'test')

outputBasePath <- 'data/training_images_sorted/Danum'

NoiseMalaysiaRecIDun <- unique(NoiseMalaysiaRecID)

CombinedNoise <- list(train_idx_Noise,valid_idx_Noise,test_idx_Noise)

for (y in 1:3) {
  
  # Determine the DataType based on the index
  if (y ==1 ) {
    DataType <- FolderVec[1]
  } else if (y ==2) {
    DataType <- FolderVec[2]
  } else {
    DataType <- FolderVec[3]
  }
  
  subset_directory <- file.path(outputBasePath, DataType, 'Noise/')
  
  if (!dir.exists(subset_directory)) {
    dir.create(subset_directory, recursive = TRUE)
    message('Created output dir: ', subset_directory)
  } else {
    message(subset_directory, ' already exists')
  }
  
  ImageIndices <-  unlist(CombinedNoise[[y]])
  
  file.copy( NoiseMalaysia[ImageIndices],
             paste(subset_directory,basename(NoiseMalaysia[ImageIndices]),sep = '' ))
  
}


# Cambodia Sorting --------------------------------------------------------
GibbonsCambodia1 <- list.files('data/trainingimages/imagesCambodia/train/Gibbons',
                               full.names = T)

GibbonsCambodia2 <- list.files('data/trainingimages/imagesCambodia/valid/Gibbons',
                               full.names = T)

GibbonsCambodia3 <- list.files('data/trainingimages/imagesCambodia/test/Gibbons',
                               full.names = T)

GibbonsCambodia <- c(GibbonsCambodia1,GibbonsCambodia2,GibbonsCambodia3)

GibbonsCambodiaSplit <- str_split_fixed(GibbonsCambodia,pattern = '_',n=6)

GibbonsCambodiaRecorder <- GibbonsCambodiaSplit[,3]
GibbonsCambodiaDate <- GibbonsCambodiaSplit[,4]
GibbonsCambodiaTime <- GibbonsCambodiaSplit[,5]

GibbonsCambodiaRecID <- paste(GibbonsCambodiaRecorder,GibbonsCambodiaDate,GibbonsCambodiaTime,
                              sep='_')

table(GibbonsCambodiaRecorder)

train_idx_Gibbons <- which(GibbonsCambodiaRecorder=="R1023"|
                             GibbonsCambodiaRecorder=="R1024"|
                             GibbonsCambodiaRecorder=="R1025")

valid_idx_Gibbons <- which(GibbonsCambodiaRecorder=="R1050"|
                             GibbonsCambodiaRecorder=="R1053")

test_idx_Gibbons <-  which(GibbonsCambodiaRecorder=="R1060"|
                             GibbonsCambodiaRecorder=="R1062"|
                             GibbonsCambodiaRecorder=="R1063"|
                             GibbonsCambodiaRecorder=="R1064")

FolderVec <- c('train','valid', 'test')

outputBasePath <- 'data/training_images_sorted/Jahoo'

GibbonsCambodiaRecIDun <- unique(GibbonsCambodiaRecID)

CombinedGibbons <- list(train_idx_Gibbons,valid_idx_Gibbons,test_idx_Gibbons)

for (y in 1:3) {
  
  # Determine the DataType based on the index
  if (y ==1 ) {
    DataType <- FolderVec[1]
  } else if (y ==2) {
    DataType <- FolderVec[2]
  } else {
    DataType <- FolderVec[3]
  }
  
  subset_directory <- file.path(outputBasePath, DataType, 'Gibbons/')
  
  if (!dir.exists(subset_directory)) {
    dir.create(subset_directory, recursive = TRUE)
    message('Created output dir: ', subset_directory)
  } else {
    message(subset_directory, ' already exists')
  }
  
  ImageIndices <-  unlist(CombinedGibbons[[y]])
  
  
  file.copy( GibbonsCambodia[ImageIndices],
             paste(subset_directory,basename(GibbonsCambodia[ImageIndices]),sep = '' ))
  
}



NoiseCambodia1 <- list.files('data/trainingimages/imagesCambodia/train/Noise',
                             full.names = T)

NoiseCambodia2 <- list.files('data/trainingimages/imagesCambodia/valid/Noise',
                             full.names = T)

NoiseCambodia3 <- list.files('data/trainingimages/imagesCambodia/test/Noise',
                             full.names = T)

NoiseCambodia <- c(NoiseCambodia1,NoiseCambodia2,NoiseCambodia3)

NoiseCambodiaSplit <- str_split_fixed(NoiseCambodia,pattern = '_',n=5)

NoiseCambodiaRecorder <- NoiseCambodiaSplit[,2]
NoiseCambodiaDate <- NoiseCambodiaSplit[,3]
NoiseCambodiaTime <- NoiseCambodiaSplit[,4]

NoiseCambodiaRecID <- paste(NoiseCambodiaRecorder,NoiseCambodiaDate,NoiseCambodiaTime,
                            sep='_')

train_idx_Noise <- which(NoiseCambodiaRecorder=="R1023"|
                             NoiseCambodiaRecorder=="R1024"|
                             NoiseCambodiaRecorder=="R1025")

valid_idx_Noise <- which(NoiseCambodiaRecorder=="R1050"|
                             NoiseCambodiaRecorder=="R1053")

test_idx_Noise <-  which(NoiseCambodiaRecorder=="R1060"|
                             NoiseCambodiaRecorder=="R1062"|
                             NoiseCambodiaRecorder=="R1063"|
                             NoiseCambodiaRecorder=="R1064")


FolderVec <- c('train','valid', 'test')

outputBasePath <- 'data/training_images_sorted/Jahoo'

NoiseCambodiaRecIDun <- unique(NoiseCambodiaRecID)

CombinedNoise <- list(train_idx_Noise,valid_idx_Noise,test_idx_Noise)

for (y in 1:3) {
  
  # Determine the DataType based on the index
  if (y ==1 ) {
    DataType <- FolderVec[1]
  } else if (y ==2) {
    DataType <- FolderVec[2]
  } else {
    DataType <- FolderVec[3]
  }
  
  subset_directory <- file.path(outputBasePath, DataType, 'Noise/')
  
  if (!dir.exists(subset_directory)) {
    dir.create(subset_directory, recursive = TRUE)
    message('Created output dir: ', subset_directory)
  } else {
    message(subset_directory, ' already exists')
  }
  
  ImageIndices <-  unlist(CombinedNoise[[y]])
  
  file.copy( NoiseCambodia[ImageIndices],
             paste(subset_directory,basename(NoiseCambodia[ImageIndices]),sep = '' ))
  
}


