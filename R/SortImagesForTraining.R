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

NoiseSamplesN <- c(350,75,75)

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
  
  ImageIndices <- sample(ImageIndices,NoiseSamplesN[y],replace = F)
  
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

NoiseSamplesN <- c(150,35,35)

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
  
  ImageIndices <- sample(ImageIndices,NoiseSamplesN[y],replace = F)
  
  file.copy( NoiseCambodia[ImageIndices],
             paste(subset_directory,basename(NoiseCambodia[ImageIndices]),sep = '' ))
  
}


# Summary of training, validation, and test splits

TrainDanumGibbons <- list.files('data/training_images_sorted/Danum/train/Gibbons/')
TrainDanumNoise <- list.files('data/training_images_sorted/Danum/train/Noise/')
TrainDanumGibbonsN <- length(TrainDanumGibbons)
TrainDanumNoiseN <- length(TrainDanumNoise)

ValidDanumGibbons <- list.files('data/training_images_sorted/Danum/valid/Gibbons/')
ValidDanumNoise <- list.files('data/training_images_sorted/Danum/valid/Noise/')
ValidDanumGibbonsN <- length(ValidDanumGibbons)
ValidDanumNoiseN <- length(ValidDanumNoise)

TestDanumGibbons <- list.files('data/training_images_sorted/Danum/test/Gibbons/')
TestDanumNoise <- list.files('data/training_images_sorted/Danum/test/Noise/')
TestDanumGibbonsN <- length(TestDanumGibbons)
TestDanumNoiseN <- length(TestDanumNoise)


CombinedDanum <- cbind.data.frame(TrainDanumGibbonsN,TrainDanumNoiseN,ValidDanumGibbonsN,ValidDanumNoiseN,
                 TestDanumGibbonsN,TestDanumNoiseN)

CombinedDanum


TrainJahooGibbons <- list.files('data/training_images_sorted/Jahoo/train/Gibbons/')
TrainJahooNoise <- list.files('data/training_images_sorted/Jahoo/train/Noise/')
TrainJahooGibbonsN <- length(TrainJahooGibbons)
TrainJahooNoiseN <- length(TrainJahooNoise)

ValidJahooGibbons <- list.files('data/training_images_sorted/Jahoo/valid/Gibbons/')
ValidJahooNoise <- list.files('data/training_images_sorted/Jahoo/valid/Noise/')
ValidJahooGibbonsN <- length(ValidJahooGibbons)
ValidJahooNoiseN <- length(ValidJahooNoise)

TestJahooGibbons <- list.files('data/training_images_sorted/Jahoo/test/Gibbons/')
TestJahooNoise <- list.files('data/training_images_sorted/Jahoo/test/Noise/')
TestJahooGibbonsN <- length(TestJahooGibbons)
TestJahooNoiseN <- length(TestJahooNoise)


CombinedJahoo <- cbind.data.frame(TrainJahooGibbonsN,TrainJahooNoiseN,ValidJahooGibbonsN,ValidJahooNoiseN,
                                  TestJahooGibbonsN,TestJahooNoiseN)

colnames(CombinedJahoo) <- c('Training samples (Gibbon)',
                             'Training samples (Noise)',
                             'Validation samples (Gibbon)',
                             'Validation samples (Noise)',
                             'Test samples (Gibbon)',
                             'Test samples (Noise)')

colnames(CombinedDanum) <- c('Training samples (Gibbon)',
                   'Training samples (Noise)',
                   'Validation samples (Gibbon)',
                   'Validation samples (Noise)',
                   'Test samples (Gibbon)',
                   'Test samples (Noise)')


CombinedDanum$Species <- 'Grey Gibbon'
CombinedJahoo$Species <- 'Crested Gibbon'


CombinedDanum$Data<-  'Danum Valley Conservation Training Data'
CombinedJahoo$Data <-  'Jahoo Training Data'

CombinedSampleSize <- rbind.data.frame(CombinedDanum,CombinedJahoo)

CombinedSampleSize <- CombinedSampleSize[,c(8,7,1:6)]

CombinedSampleSizeFlex <- flextable::flextable(CombinedSampleSize)

CombinedSampleSizeFlex

flextable::save_as_docx(CombinedSampleSizeFlex,
                        path='Table XX Training data summary.docx')

