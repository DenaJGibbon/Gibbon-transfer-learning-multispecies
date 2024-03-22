# Generalizability of pre-trained models
library(tuneR)
library(seewave)
library(signal)
library(stringr)

# Jahoo data prep --------------------------------------------------------

JahooBoxDrive <-'/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/AnnotatedFiles'

# Prepare selection tables ------------------------------------------------

# List selection table full names
SelectionTables <- 
  list.files(JahooBoxDrive,pattern = '.txt',full.names = T,recursive = T)

# List selection table short names
SelectionTablesShort <- 
  list.files(JahooBoxDrive,pattern = '.txt',recursive = T)

# Remove .txt
SelectionTablesID <- str_split_fixed(SelectionTablesShort,pattern = '.Table',n=2)[,1]

# Start with one file 
JahooWavs <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/SoundFiles'

SoundFilePathFull <- list.files(JahooWavs,full.names = T,recursive = T,pattern = '.wav')

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

  print(unique(TempAnnotations$Class))
  
  #TempAnnotationsGibbon <- subset(TempAnnotations,Class=='female.gibbon')
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
  
  ClipIndexList <- list()
  
  for(c in 1:nrow(TempAnnotations)){
    TempRow <- TempAnnotations[c,]
    
    StartTime <- as.numeric(TempRow$Begin.Time..s.)
    EndTime <- as.numeric(TempRow$End.Time..s.)

  
    # Filter the clips based on the condition for ClipStart and ClipEnd
    ClipIndex <- which( ClipDataFrame$ClipStart >= StartTime-8 & ClipDataFrame$ClipEnd <= EndTime+8)
    TempClips <- ClipDataFrame[ ClipIndex,]
    
  
    TempClass <- TempRow$Class
    
    
    if(nrow(TempClips) >1){
      ClipIndexList[[c]] <- ClipIndex
      subset.directory <- paste('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/Clips/',TempClass,sep='')
      
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
      
      
      
      for(d in 1:length(short.sound.files)){
        
        writeWave(short.sound.files[[d]],paste(subset.directory,'/',
                                               TempClass,'_',AnnotationsPathShort[b],'_',TempClips$ClipEnd[d], '.wav', sep=''),
                  extensible = F)
      }
      
    }
  }
  
  TempClipsNoise <-  ClipDataFrame[-unlist(ClipIndexList),]
  TempClassNoise <- 'Noise'
  if(nrow(TempClipsNoise) >1 ){
    subset.directory <- paste('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/Clips/',TempClassNoise,sep='')
    
    if (!dir.exists(subset.directory)){
      dir.create(subset.directory)
      print(paste('Created output dir',subset.directory))
    } else {
      print(paste(subset.directory,'already exists'))
    }
    short.sound.files <- lapply(1:nrow(TempClipsNoise),
                                function(i)
                                  extractWave(
                                    TempWav,
                                    from = TempClipsNoise$ClipStart[i],
                                    to = TempClipsNoise$ClipEnd[i],
                                    xunit = c("time"),
                                    plot = F,
                                    output = "Wave"
                                  ))
    
    
    # Randomly choose some noise clips
    RanSeq <- seq(1,length(short.sound.files),1)
    
    for(d in RanSeq){
      
      writeWave(short.sound.files[[d]],paste(subset.directory,'/',
                                             TempClassNoise,'_',AnnotationsPathShort[b],'_',TempClipsNoise$ClipEnd[d], '.wav', sep=''),
                extensible = F)
    }
    
  }
}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}


# Image creation -----------------------------------------------
TrainingFolders <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/Clips/',full.names = T)
TrainingFoldersShort <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/Clips/',full.names = F)
OutputFolder <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/Images/'

for(z in 1:length(TrainingFolders)){
  SoundFiles <- list.files(TrainingFolders[z], recursive = T,full.names = T, pattern = '.wav')
  SoundFilesShort <- list.files(TrainingFolders[z], recursive = T,full.names = F, pattern = '.wav')
  
  for(y in 1:length(SoundFiles)){
    
    
    subset.directory <- paste(OutputFolder,TrainingFoldersShort[z],sep='/')
    
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


# DanumValley data prep --------------------------------------------------------

DanumValleyBoxDrive <-'/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/AnnotatedFiles'

# Prepare selection tables ------------------------------------------------

# List selection table full names
SelectionTables <- 
  list.files(DanumValleyBoxDrive,pattern = '.txt',full.names = T,recursive = T)

# List selection table short names
SelectionTablesShort <- 
  list.files(DanumValleyBoxDrive,pattern = '.txt',recursive = T)

# Remove .txt
SelectionTablesID <- str_split_fixed(SelectionTablesShort,pattern = '.Table',n=2)[,1]

# Start with one file 
DanumValleyWavs <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/SoundFiles'

SoundFilePathFull <- list.files(DanumValleyWavs,full.names = T,recursive = T,pattern = '.wav')

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
  
  print(unique(TempAnnotations$Call.type))
  
  TempAnnotations <- subset(TempAnnotations,Call.type=='female.gibbon')
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
  
  ClipIndexList <- list()
  
  for(c in 1:nrow(TempAnnotations)){
    TempRow <- TempAnnotations[c,]
    
    StartTime <- as.numeric(TempRow$Begin.Time..s.)
    EndTime <- as.numeric(TempRow$End.Time..s.)
    
    
    # Filter the clips based on the condition for ClipStart and ClipEnd
    ClipIndex <- which( ClipDataFrame$ClipStart >= StartTime-6 & ClipDataFrame$ClipStart <= StartTime+6)
    TempClips <- ClipDataFrame[ ClipIndex,]
    
    
    TempClass <- 'GreyGibbons'
    
    
    if(nrow(TempClips) >1){
      ClipIndexList[[c]] <- ClipIndex
      subset.directory <- paste('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/Clips/',TempClass,sep='')
      
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
      
      
      
      for(d in 1:length(short.sound.files)){
        
        writeWave(short.sound.files[[d]],paste(subset.directory,'/',
                                               TempClass,'_',AnnotationsPathShort[b],'_',TempClips$ClipEnd[d], '.wav', sep=''),
                  extensible = F)
      }
      
    }
  }
  
  TempClipsNoise <-  ClipDataFrame[-unlist(ClipIndexList),]
  TempClassNoise <- 'Noise'
  if(nrow(TempClipsNoise) >1 ){
    subset.directory <- paste('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/Clips/',TempClassNoise,sep='')
    
    if (!dir.exists(subset.directory)){
      dir.create(subset.directory)
      print(paste('Created output dir',subset.directory))
    } else {
      print(paste(subset.directory,'already exists'))
    }
    short.sound.files <- lapply(1:nrow(TempClipsNoise),
                                function(i)
                                  extractWave(
                                    TempWav,
                                    from = TempClipsNoise$ClipStart[i],
                                    to = TempClipsNoise$ClipEnd[i],
                                    xunit = c("time"),
                                    plot = F,
                                    output = "Wave"
                                  ))
    
    
    # Randomly choose some noise clips
    RanSeq <- seq(1,length(short.sound.files),1)
    RanSeq <- sample(RanSeq, size = length(short.sound.files)/4)
    
    for(d in RanSeq){
      
      writeWave(short.sound.files[[d]],paste(subset.directory,'/',
                                             TempClassNoise,'_',AnnotationsPathShort[b],'_',TempClipsNoise$ClipEnd[d], '.wav', sep=''),
                extensible = F)
    }
    
  }
}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}


# Image creation -----------------------------------------------
TrainingFolders <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/Clips/',full.names = T)
TrainingFoldersShort <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/Clips/',full.names = F)
OutputFolder <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/Images/'

for(z in 1:length(TrainingFolders)){
  SoundFiles <- list.files(TrainingFolders[z], recursive = T,full.names = T, pattern = '.wav')
  SoundFilesShort <- list.files(TrainingFolders[z], recursive = T,full.names = F, pattern = '.wav')
  
  for(y in 1:length(SoundFiles)){
    
    
    subset.directory <- paste(OutputFolder,TrainingFoldersShort[z],sep='/')
    
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
    seewave::spectro(short.wav,tlab='',flab='',axisX=F,axisY = F,flim=c(0.4,2),scale=F,grid=F,noisereduction=1)
    graphics.off()
    
  }
}

