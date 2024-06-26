# Prepare data ------------------------------------------------------------
# setwd("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")
# devtools::document()
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

# NEED TO ADD:  metadata output

# Set the output folder paths
OutputFolder <- '/Users/denaclink/Desktop/DanumSparseArray/Detections/'
OutputFolderSelections <- '/Users/denaclink/Desktop/DanumSparseArray/SelectionTables/'
OutputFolderWav <- '/Users/denaclink/Desktop/DanumSparseArray/Wavs/'

# Import trained model
# Chose because had highest precision while maintaining recall
TopModel <- luz_load("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/_imagesmalaysia_unfrozen_TRUE_/_imagesmalaysia_20_modelResNet152.pt")


path.to.files <- '/Volumes/Dena Clink Toshiba 3 TB/SWIFT_sparse_array_Danum/'
# Already run above this line #

#
# path.to.files <-'/Users/denaclink/Library/CloudStorage/Box-Box/Cambodia 2022/Acoustics Gibbon PAM_04_03_23'
# Doesn't have all 10 #/Users/denaclink/Library/CloudStorage/Box-Box/Cambodia 2022/Acoustics Gibbon PAM_08_07_23'

# Get a list of full file paths of sound files in a directory
SoundFilePathFull <- list.files(path.to.files,
                                recursive = T, pattern = '.wav', full.names = T)

# Get a list of file names of sound files in a directory
SoundFilePathShort <- list.files(path.to.files,
                                 recursive = T, pattern = '.wav')



SoundFilePathShort <- basename(SoundFilePathShort)

# Extract only the file names without the extension
SoundFilePathShort <- str_split_fixed(SoundFilePathShort,
                                      pattern = '.wav', n = 2)[,1]


times <- substr(str_split_fixed(SoundFilePathShort,
                                pattern = '_', n=3)[,3],1,2)

# Define the range of times you want to select
selected_times <- as.numeric(4:12)

# Filter the full file paths and file names based on the selected times
times.index <- which( as.numeric(times) %in% selected_times)
SoundFilePathFull <- SoundFilePathFull[times.index]
SoundFilePathShort <- SoundFilePathShort[times.index]


# Set parameters for processing sound clips
clip.duration <- 12       # Duration of each sound clip
hop.size <- 6             # Hop size for splitting the sound clips
downsample.rate <- 16000   # Downsample rate for audio in Hz, otherwise NA
threshold <- 0.5         # Threshold for audio detection
sav.wav <- T              # Save the extracted sound clips as WAV files?
UniqueClassesTraining <- c('Gibbons','Noise')
noise.category <- 'Noise'
MaxFreq.khz <- 2
single.class <- TRUE
single.class.category <- 'Gibbons'
model.type <- 'binary'

# Create output folders if they don't exist
dir.create(OutputFolder, recursive = TRUE, showWarnings = FALSE)
dir.create(OutputFolderSelections, recursive = TRUE, showWarnings = FALSE)
dir.create(OutputFolderWav, recursive = TRUE, showWarnings = FALSE)

for(x in (1:length(SoundFilePathFull)) ){ tryCatch({
  RavenSelectionTableDFTopModel <- data.frame()
  
  start.time.detection <- Sys.time()
  print(paste(x, 'out of', length(SoundFilePathFull)))
  TempWav <- readWave(SoundFilePathFull[x])
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
  
  TempClips <- cbind.data.frame(ClipStart,ClipEnd)
  
  # Subset sound clips for classification -----------------------------------
  print('saving sound clips')
  set.seed(13)
  length <- nrow(TempClips)
  
  if(length > 100){
    length.files <- seq(1,length,100)
  } else {
    length.files <- c(1,length)
  }
  
  for(q in 1: (length(length.files)-1) ){
    unlink('/Users/denaclink/Desktop/data/Temp/WavFiles', recursive = TRUE)
    unlink('/Users/denaclink/Desktop/data/Temp/Images/Images', recursive = TRUE)
    
    dir.create('/Users/denaclink/Desktop/data/Temp/WavFiles')
    dir.create('/Users/denaclink/Desktop/data/Temp/Images/Images')
    
    RandomSub <-  seq(length.files[q],length.files[q+1],1)
    
    if(q== (length(length.files)-1) ){
      RandomSub <-  seq(length.files[q],length,1)
    }
    
    start.time <- TempClips$ClipStart[RandomSub]
    end.time <- TempClips$ClipEnd[RandomSub]
    
    short.sound.files <- lapply(1:length(start.time),
                                function(i)
                                  extractWave(
                                    TempWav,
                                    from = start.time[i],
                                    to = end.time[i],
                                    xunit = c("time"),
                                    plot = F,
                                    output = "Wave"
                                  ))
    
    if(downsample.rate != 'NA'){
      print('downsampling')
      short.sound.files <- lapply(1:length(short.sound.files),
                                  function(i)
                                    downsample(
                                      short.sound.files[[i]],
                                      samp.rate=downsample.rate
                                    ))
    }
    
    for(d in 1:length(short.sound.files)){
      #print(d)
      writeWave(short.sound.files[[d]],paste('/Users/denaclink/Desktop/data/Temp/WavFiles','/',
                                             SoundFilePathShort[x],'_',start.time[d], '.wav', sep=''),
                extensible = F)
    }
    
    # Save images to a temp folder
    print(paste('Creating images',start.time[1],'start time clips'))
    
    for(e in 1:length(short.sound.files)){
      jpeg(paste('/Users/denaclink/Desktop/data/Temp/Images/Images','/', SoundFilePathShort[x],'_',start.time[e],'.jpg',sep=''),res = 50)
      short.wav <- short.sound.files[[e]]
      
      seewave::spectro(short.wav,tlab='',flab='',axisX=F,axisY = F,scale=F,grid=F,flim=c(0.4,MaxFreq.khz),fastdisp=TRUE,noisereduction=1)
      
      graphics.off()
    }
    
    # Predict using TopModel ----------------------------------------------------
    print('Classifying images using Top Model')
    
    test.input <- '/Users/denaclink/Desktop/data/Temp/Images/'
    
    # ResNet
    test_ds <- image_folder_dataset(
      file.path(test.input),
      transform = . %>%
        torchvision::transform_to_tensor() %>%
        torchvision::transform_resize(size = c(224, 224)) %>%
        torchvision::transform_normalize(mean = c(0.485, 0.456, 0.406), std = c(0.229, 0.224, 0.225)))
    
    
    # Predict the test files
    # Variable indicating the number of files
    
    # Load the test images
    test_dl <- dataloader(test_ds, batch_size =32, shuffle = F)
    
    # Predict using TopModel
    TopModelPred <- predict(TopModel, test_dl)
    
    if(model.type!='binary'){
    # Return the index of the max values (i.e. which class)
    PredMPS <- torch_argmax(TopModelPred, dim = 2)
    
    # Save to cpu
    PredMPS <- as_array(torch_tensor(PredMPS, device = 'cpu'))
    
    # Convert to a factor
    modelResnetPred <- as.factor(PredMPS)
    

    # Calculate the probability associated with each class
    Probability <- as_array(torch_tensor(nnf_softmax(TopModelPred, dim = 2), device = 'cpu'))
    
    # Find the index of the maximum value in each row
    max_prob_idx <- apply(Probability, 1, which.max)
    
    # Map the index to actual probability
    predicted_class_probability <- sapply(1:nrow(Probability), function(i) Probability[i, max_prob_idx[i]])
    
    # Convert the integer predictions to factor and then to character based on the levels
    modelResnetNames <- factor(modelResnetPred, levels = 1:length(UniqueClassesTraining), labels = UniqueClassesTraining)
    
    }
    
    if(model.type=='binary'){
      # Predict using TopModel
      TopModelPred <- predict(TopModel, test_dl)
      
      BinaryProb <- torch_sigmoid(TopModelPred)
      predicted_class_probability <-  1- as_array(torch_tensor(BinaryProb, device = 'cpu'))
      modelResnetNames <- ifelse((predicted_class_probability) > threshold, 'Gibbons', 'Noise')
      
    }
    
    outputTableTopModel <- cbind.data.frame(modelResnetNames, predicted_class_probability)
    colnames(outputTableTopModel) <- c('PredictedClass', 'Probability')
    
    image.files <- list.files(file.path(test.input),recursive = T,
                              full.names = T)
    nslash <- str_count(image.files,'/')+1
    nslash <- nslash[1]
    image.files.short <- str_split_fixed(image.files,pattern = '/',n=nslash)[,nslash]
    image.files.short <- str_split_fixed(image.files.short,pattern = '.jpg',n=2)[,1]
    
    print('Saving output')
    
    Detections <-  which(outputTableTopModel$Probability >= threshold &
                           outputTableTopModel$PredictedClass != noise.category )
    
    if(single.class =='TRUE'){
      Detections <-  which(outputTableTopModel$Probability >= threshold &
                             outputTableTopModel$PredictedClass == single.class.category )
      
      
    }
    
    Detections <-  split(Detections, cumsum(c(
      1, diff(Detections)) != 1))
    
    for(i in 1:length(Detections)){
      TempList <- Detections[[i]]
      if(length(TempList)==1){
        Detections[[i]] <- TempList[1]
      }
      if(length(TempList)==2){
        Detections[[i]] <- TempList[2]
      }
      if(length(TempList)> 2){
        Detections[[i]] <- median(TempList)
      }
      
    }
    
    DetectionIndices <- unname(unlist(Detections))
    
    DetectionClass <-  outputTableTopModel$PredictedClass[DetectionIndices]
    
    
    print('Saving output')
    file.copy(image.files[DetectionIndices],
              to= paste(OutputFolder, DetectionClass,'_',
                        image.files.short[DetectionIndices],
                        '_',
                        round(predicted_class_probability[DetectionIndices],2),
                        '_TopModel_.jpg', sep=''))
    
    if(sav.wav ==T){
      wav.file.paths <- list.files('/Users/denaclink/Desktop/data/Temp/WavFiles',full.names = T)
      file.copy(wav.file.paths[DetectionIndices],
                to= paste(OutputFolderWav,  DetectionClass,'_',
                          image.files.short[DetectionIndices],
                          '_',
                          round(predicted_class_probability[DetectionIndices],2),
                          '_TopModel_.wav', sep=''))
    }
    
    Detections <- image.files.short[DetectionIndices]
    
    
    if (length(Detections) > 0) {
      Selection <- seq(1, length(Detections))
      View <- rep('Spectrogram 1', length(Detections))
      Channel <- rep(1, length(Detections))
      MinFreq <- rep(100, length(Detections))
      MaxFreq <- rep(2000, length(Detections))
      start.time.new <- as.numeric(str_split_fixed(Detections,pattern = '_',n=4)[,4])
      end.time.new <- start.time.new + clip.duration
      Probability <- round(predicted_class_probability[DetectionIndices],2)
      
      RavenSelectionTableDFTopModelTemp <-
        cbind.data.frame(Selection,
                         View,
                         Channel,
                         MinFreq,
                         MaxFreq,start.time.new,end.time.new,Probability,
                         Detections)
      
      RavenSelectionTableDFTopModelTemp <-
        RavenSelectionTableDFTopModelTemp[, c(
          "Selection",
          "View",
          "Channel",
          "start.time.new",
          "end.time.new",
          "MinFreq",
          "MaxFreq",
          'Probability',"Detections"
        )]
      
      colnames(RavenSelectionTableDFTopModelTemp) <-
        c(
          "Selection",
          "View",
          "Channel",
          "Begin Time (s)",
          "End Time (s)",
          "Low Freq (Hz)",
          "High Freq (Hz)",
          'Probability',
          "Detections"
        )
      
      
      if(nrow(RavenSelectionTableDFTopModelTemp) > 0){
        csv.file.name <-
          paste(OutputFolderSelections, paste(unique(DetectionClass),'_',sep='-'),'_',
                SoundFilePathShort[x],
                'GibbonTopModelAllFilesMalaysia.txt',
                sep = '')
        
        RavenSelectionTableDFTopModel <- rbind.data.frame(RavenSelectionTableDFTopModel,
                                                       RavenSelectionTableDFTopModelTemp)
        
        RavenSelectionTableDFTopModel$Class <- DetectionClass
        
        write.table(
          x = RavenSelectionTableDFTopModel,
          sep = "\t",
          file = csv.file.name,
          row.names = FALSE,
          quote = FALSE
        )
        print(paste(
          "Saving Selection Table"
        ))
      }
      
      
    }
  }
  
  if(nrow(RavenSelectionTableDFTopModel) == 0){
    csv.file.name <-
      paste(OutputFolderSelections, paste(unique(DetectionClass),'_',sep='-'),'_',
            SoundFilePathShort[x],
            'GibbonTopModelAllFilesMalaysia.txt',
            sep = '')
    
    
    ColNames <-  c(
      "Selection",
      "View",
      "Channel",
      "Begin Time (s)",
      "End Time (s)",
      "Low Freq (Hz)",
      "High Freq (Hz)",
      'Probability',
      "Detections"
    )
    
    TempNARow <- t(as.data.frame(rep(NA,length(ColNames))))
    
    colnames(TempNARow) <- ColNames
    
    write.table(
      x = TempNARow,
      sep = "\t",
      file = csv.file.name,
      row.names = FALSE,
      quote = FALSE
    )
    print(paste(
      "Saving Selection Table"
    ))
  }
  
  rm(TempWav)
  rm(short.sound.files)
  rm( test_ds )
  rm(short.wav)
  end.time.detection <- Sys.time()
  print(end.time.detection-start.time.detection)
  gc()
}, error = function(e) { cat("ERROR :", conditionMessage(e), "\n") })
}



