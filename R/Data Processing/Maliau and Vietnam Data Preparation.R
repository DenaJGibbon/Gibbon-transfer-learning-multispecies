# Generalizability of pre-trained models
library(tuneR)
library(seewave)
library(signal)
library(stringr)

# Vietnam data prep --------------------------------------------------------

VietnamBoxDrive <-'/Users/denaclink/Library/CloudStorage/GoogleDrive-djc426@cornell.edu/.shortcut-targets-by-id/1OctfGGx795FfNLY4I64JyJ5lMWs4FRL5/Gibbon Call/'

# Prepare selection tables ------------------------------------------------

# List selection table full names
SelectionTables <- 
  list.files(VietnamBoxDrive,pattern = '.txt',full.names = T,recursive = T)

# List selection table short names
SelectionTablesShort <- 
  list.files(VietnamBoxDrive,pattern = '.txt',recursive = T)

# Remove .txt
SelectionTablesID <- str_split_fixed(SelectionTablesShort,pattern = '.Table',n=2)[,1]

# Start with one file 
SoundFilePathFull <- list.files(VietnamBoxDrive,full.names = T,recursive = T,pattern = '.wav')

nslash <- str_count(SoundFilePathFull[1],'/')

SoundFilePathShort <- str_split_fixed(SoundFilePathFull,
                                      pattern = '/',n=nslash)[,nslash]

SoundFilePathShort <- str_split_fixed(SoundFilePathShort,
                                      pattern = '.wav',n=2)[,1]

SoundFilePathShort <- str_replace(SoundFilePathShort, '/', '_')
                                     

AnnotationsPathFull <- SelectionTables


AnnotationsPathShort <- str_replace(SelectionTablesID, '/', '_')

clip.duration <- 12       # Duration of each sound clip
hop.size <- 6             # Hop size for splitting the sound clips

for( b in 1: length(AnnotationsPathFull)){tryCatch({
  print(b)
  WavIndex <- which(str_detect(SoundFilePathShort,AnnotationsPathShort[b]))
  
  TempAnnotations <- read.delim2(AnnotationsPathFull[b])
  TempAnnotations <- subset(TempAnnotations,View=="Spectrogram 1")
  TempAnnotations$Call.type <- 'Gibbon'
  print(unique(TempAnnotations$Call.type))
  
  #TempAnnotationsGibbon <- subset(TempAnnotations,Call.type=='female.gibbon')
  TempWav <- readWave(SoundFilePathFull[WavIndex])
  WavDur <- duration(TempWav)
  
  Seq.start <- list()
  Seq.end <- list()
  
  i <- 1
  while (i + clip.duration < WavDur) {
    # print(i)
    Seq.start[[i]] = i
    Seq.end[[i]] = i+clip.duration
    i= i+hop.size
  }
  
  ClipStart <- unlist(Seq.start)
  ClipEnd <- unlist(Seq.end)
  
  ClipDataFrame <- cbind.data.frame(ClipStart,ClipEnd)
  
  TempClipsCombinedNoise <- data.frame()
  
  for(c in 1:nrow(TempAnnotations)){
    TempRow <- TempAnnotations[c,]
    
    StartTime <- as.numeric(TempRow$Begin.Time..s.)
    EndTime <- as.numeric(TempRow$End.Time..s.)

  
    # Filter the clips based on the condition for ClipStart and ClipEnd
    TempClips <- ClipDataFrame[ ClipDataFrame$ClipStart >= StartTime-4 & ClipDataFrame$ClipEnd <= EndTime+4,]
    
    
    if(nrow(TempClips)>0){
      TempClipsNoise <- ClipDataFrame[-(ClipDataFrame$ClipStart >= StartTime-4 & ClipDataFrame$ClipEnd <= EndTime+4),]
    } else{
      TempClipsNoise <- ClipDataFrame
      
    }
    
    TempClipsCombinedNoise <- rbind.data.frame(TempClipsCombinedNoise,TempClipsNoise )
    
    TempClass <- TempRow$Call.type
    
    
    TempClassNoise <- 'Noise'
    
    
    if(nrow(TempClips) >1){
      
      subset.directory <- paste('/Volumes/DJC Files/Danum Deep Learning/MultiSpeciesAnalysis/ValidationClipsVietnam/',TempClass,sep='')
      
      if (!dir.exists(subset.directory)){
        dir.create(subset.directory)
        print(paste('Created output dir',subset.directory))
      } else {
        print(paste(subset.directory,'already exists'))
      }
      short.sound.files <- lapply(1:nrow(TempClips),
                                  function(i)
                                    extractWave(
                                      TempWav,
                                      from = TempClips$ClipStart[i],
                                      to = TempClips$ClipEnd[i],
                                      xunit = c("time"),
                                      plot = F,
                                      output = "Wave"
                                    ))
      
      short.sound.files <- lapply(1:length(short.sound.files),
                                  function(i)
                                    downsample(
                                      short.sound.files[[i]],32000
                                    ))
      
      for(d in 1:length(short.sound.files)){
        
        writeWave(short.sound.files[[d]],paste(subset.directory,'/',
                                               TempClass,'_',AnnotationsPathShort[b],'_',TempClips$ClipEnd[d], '.wav', sep=''),
                  extensible = F)
      }
      
    }
  }
  
  
  if(nrow(TempClipsCombinedNoise) >1 ){
    subset.directory <- paste('/Volumes/DJC Files/Danum Deep Learning/MultiSpeciesAnalysis/ValidationClipsVietnam/',TempClassNoise,sep='')
    
    if (!dir.exists(subset.directory)){
      dir.create(subset.directory)
      print(paste('Created output dir',subset.directory))
    } else {
      print(paste(subset.directory,'already exists'))
    }
    short.sound.files <- lapply(1:nrow(TempClipsCombinedNoise),
                                function(i)
                                  extractWave(
                                    TempWav,
                                    from = TempClipsCombinedNoise$ClipStart[i],
                                    to = TempClipsCombinedNoise$ClipEnd[i],
                                    xunit = c("time"),
                                    plot = F,
                                    output = "Wave"
                                  ))
    
    short.sound.files <- lapply(1:length(short.sound.files),
                                function(i)
                                  downsample(
                                    short.sound.files[[i]],32000
                                  ))
    
    # Randomly choose some noise clips
    RanSeq <- sample(1:length(short.sound.files),16,replace = F)
    for(d in RanSeq){
      
      writeWave(short.sound.files[[d]],paste(subset.directory,'/',
                                             TempClassNoise,'_',AnnotationsPathShort[b],'_',TempClipsCombinedNoise$ClipEnd[d], '.wav', sep=''),
                extensible = F)
    }
    
  }
}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}


# Image creation -----------------------------------------------
TrainingFolders <- list.files("/Volumes/DJC Files/Danum Deep Learning/MultiSpeciesAnalysis/ValidationClipsVietnam/",full.names = T)
TrainingFoldersShort <- list.files('/Volumes/DJC Files/Danum Deep Learning/MultiSpeciesAnalysis/ValidationClipsVietnam/',full.names = F)
OutputFolder <- 'data/imagesVietnam'
FolderVec <- c('test') # Need to create these folders

for(z in 1:length(TrainingFolders)){
  SoundFiles <- list.files(TrainingFolders[z], recursive = T,full.names = T, pattern = '.wav')
  SoundFilesShort <- list.files(TrainingFolders[z], recursive = T,full.names = F, pattern = '.wav')
  
  for(y in 1:length(SoundFiles)){
    
    DataType <-  FolderVec[1]
    
    subset.directory <- paste(OutputFolder,DataType,TrainingFoldersShort[z],sep='/')
    
    if (!dir.exists(subset.directory)){
      dir.create(subset.directory)
      print(paste('Created output dir',subset.directory))
    } else {
      print(paste(subset.directory,'already exists'))
    }
    wav.rm <- str_split_fixed(SoundFilesShort[y],pattern='.wav',n=2)[,1]
    jpeg(paste(subset.directory, '/', wav.rm,'.jpg',sep=''),res = 50)
    temp.name <- SoundFiles[y]
    short.wav <-readWave(temp.name)
    seewave::spectro(short.wav,tlab='',flab='',axisX=F,axisY = F,flim=c(0.4,3),scale=F,grid=F,noisereduction=1)
    graphics.off()
    
  }
}


# Maliau Preparation ------------------------------------------------------
clip.duration <- 12       # Duration of each sound clip
hop.size <- 6             # Hop size for splitting the sound clips


MaliauBoxDrive <-'/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauBasin/SoundFiles'

# Prepare selection tables ------------------------------------------------

# List selection table full names
SelectionTables <- 
  list.files('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauBasin/AnnotatedFiles/',pattern = '.txt',full.names = T)

# List selection table short names
SelectionTablesShort <- 
  list.files('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauBasin/AnnotatedFiles/',pattern = '.txt')

# Remove .txt
SelectionTablesID <- str_split_fixed(SelectionTablesShort,pattern = '.Table',n=2)[,1]

# Start with one file 
SoundFilePathFull <- list.files(MaliauBoxDrive,full.names = T,recursive = T)

nslash <- str_count(SoundFilePathFull[1],'/')+1

SoundFilePathShort <- str_split_fixed(SoundFilePathFull,
                                      pattern = '/',n=nslash)[,nslash]

SoundFilePathShort <- str_split_fixed(SoundFilePathShort,
                                      pattern = '.wav',n=2)[,1]

AnnotationsPathFull <- SelectionTables


AnnotationsPathShort <- SelectionTablesID

clip.duration <- 12       # Duration of each sound clip
hop.size <- 6             # Hop size for splitting the sound clips

for( b in 1: length(AnnotationsPathFull)){tryCatch({
  print(b)
  WavIndex <- which(str_detect(SoundFilePathShort,AnnotationsPathShort[b]))
  
  TempAnnotations <- read.delim2(AnnotationsPathFull[b])
  TempAnnotations <- subset(TempAnnotations,Call.type=='female.gibbon')
  
  
  #TempAnnotationsGibbon <- subset(TempAnnotations,Call.type=='female.gibbon')
  TempWav <- readWave(SoundFilePathFull[WavIndex])
  WavDur <- duration(TempWav)
  
  if(nrow(TempAnnotations) >0){
    TempAnnotations$Call.type <- 'Gibbon'
    print(unique(TempAnnotations$Call.type))
  for(c in 1:nrow(TempAnnotations)){
    TempRow <- TempAnnotations[c,]
    
    StartTime <- as.numeric(TempRow$Begin.Time..s.)
    EndTime <- as.numeric(TempRow$End.Time..s.)

      
      subset.directory <- paste('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauClips/',TempClass,sep='')
      
      if (!dir.exists(subset.directory)){
        dir.create(subset.directory)
        print(paste('Created output dir',subset.directory))
      } else {
        print(paste(subset.directory,'already exists'))
      }
      short.sound.files <- lapply(1:nrow(TempClips),
                                  function(i)
                                    extractWave(
                                      TempWav,
                                      from = StartTime,
                                      to = EndTime,
                                      xunit = c("time"),
                                      plot = F,
                                      output = "Wave"
                                    ))
      
      short.sound.files <- lapply(1:length(short.sound.files),
                                  function(i)
                                    downsample(
                                      short.sound.files[[i]],16000
                                    ))
      
      for(d in 1:length(short.sound.files)){
        
        writeWave(short.sound.files[[d]],paste(subset.directory,'/',
                                               TempClass,'_',AnnotationsPathShort[b],'_',round(StartTime,2), '.wav', sep=''),
                  extensible = F)
      }
      
    }
  }
  
  TempClipsNoise <- 'Noise'
  
  
  newdata <- TempAnnotations[order(TempAnnotations$End.Time..s.),]
  LastRow <- TempAnnotations[nrow(newdata),]
  if(nrow(LastRow) >0 ){
    subset.directory <- paste('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauClips/',TempClassNoise,sep='')
    
    if (!dir.exists(subset.directory)){
      dir.create(subset.directory)
      print(paste('Created output dir',subset.directory))
    } else {
      print(paste(subset.directory,'already exists'))
    }
    
    StartTime <- sample(seq(LastRow$End.Time..s.,2376),20,replace = F)
    EndTime <- StartTime +clip.duration
    
    short.sound.files <- lapply(1:20,
                                function(i)
                                  extractWave(
                                    TempWav,
                                    from = StartTime[i],
                                    to = EndTime[i],
                                    xunit = c("time"),
                                    plot = F,
                                    output = "Wave"
                                  ))
    
    short.sound.files <- lapply(1:length(short.sound.files),
                                function(i)
                                  downsample(
                                    short.sound.files[[i]],16000
                                  ))
    
    # Randomly choose some noise clips

    for(d in 1:length(short.sound.files)){
      
      writeWave(short.sound.files[[d]],paste(subset.directory,'/',
                                             TempClassNoise,'_',AnnotationsPathShort[b],'_',TempClipsCombinedNoise$ClipEnd[d], '.wav', sep=''),
                extensible = F)
    }
    
  }
}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}


# Image creation -----------------------------------------------
TrainingFolders <- list.files("/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauClips/",full.names = T)
TrainingFoldersShort <- list.files('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauClips/',full.names = F)
OutputFolder <- '/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauImages/'
FolderVec <- c('test') # Need to create these folders

for(z in 1:length(TrainingFolders)){
  SoundFiles <- list.files(TrainingFolders[z], recursive = T,full.names = T, pattern = '.wav')
  SoundFilesShort <- list.files(TrainingFolders[z], recursive = T,full.names = F, pattern = '.wav')
  
  for(y in 1:length(SoundFiles)){
    
    DataType <-  FolderVec[1]
    
    subset.directory <- paste(OutputFolder,DataType,TrainingFoldersShort[z],sep='/')
    
    if (!dir.exists(subset.directory)){
      dir.create(subset.directory,recursive = T)
      print(paste('Created output dir',subset.directory))
    } else {
      print(paste(subset.directory,'already exists'))
    }
    wav.rm <- str_split_fixed(SoundFilesShort[y],pattern='.wav',n=2)[,1]
    jpeg(paste(subset.directory, '/', wav.rm,'.jpg',sep=''),res = 50)
    temp.name <- SoundFiles[y]
    short.wav <-readWave(temp.name)
    short.wav <- downsample(short.wav, 16000)
    seewave::spectro(short.wav,tlab='',flab='',axisX=F,axisY = F,flim=c(0.4,2),scale=F,grid=F,noisereduction=1)
    graphics.off()
    
  }
}



