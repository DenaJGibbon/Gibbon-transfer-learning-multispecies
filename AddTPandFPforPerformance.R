# Retrain with TP and FP
library(stringr)

# Remove files from training that are uused for evaluation
ListSelections <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/AnnotatedFiles',
           full.names = F)

ListSelections <- basename(ListSelections)
RecorderName <- str_split_fixed(ListSelections, pattern = '.Table', n=2)[,1]

ImageNames <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/data',recursive = T,
                         full.names = T)

for(a in 2:length(RecorderName)){
  
  ImageNamesSubset <-   ImageNames[which(str_detect(ImageNames,RecorderName[a]))]

  file.copy(from = ImageNamesSubset,
          to   = paste('/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/omit/', basename(ImageNamesSubset), sep=''))

file.remove(ImageNamesSubset)
}


# Multi species classification --------------------------------------------
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

# Location of spectrogram images for training
input.data.path <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/data/'

# Location of spectrogram images for testing
test.data.path <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/data/test/'

# Training data folder short
trainingfolder.short <- 'imagesmulti'

# Whether to unfreeze the layers
unfreeze.param <- TRUE # FALSE means the features are frozen; TRUE unfrozen

# Number of epochs to include
epoch.iterations <- c(2)

# Allow early stopping?
early.stop <- 'yes'

gibbonNetR::train_CNN_multi(input.data.path=input.data.path,
                            architecture ='resnet50',
                            learning_rate = 0.001,
                            test.data=test.data.path,
                            unfreeze = TRUE,
                            epoch.iterations=epoch.iterations,
                            save.model= TRUE,
                            early.stop = "yes",
                            output.base.path = "/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/model_output/",
                            trainingfolder=trainingfolder.short,
                            noise.category = "Noise")


TopModelMulti <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/model_output/_imagesmulti_multi_unfrozen_TRUE_/top_model/_imagesmulti_2_resnet50_model.pt'

JahooSoundFiles <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/SoundFiles/'
 
deploy_CNN_multi(
  clip_duration = 12,
  architecture='resnet',
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/gibbonNetRMulti/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/gibbonNetRMulti/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/gibbonNetRMulti/Wavs',
  #detect_pattern= 'NA',
  top_model_path = TopModelMulti,
  path_to_files = JahooSoundFiles,
  class_names = c('CrestedGibbon','GreyGibbon','Noise'),
  noise_category = 'Noise',
  single_class = TRUE,
  single_class_category='CrestedGibbon',
  save_wav = FALSE,
  threshold = .1
)


# Evaluate performance ----------------------------------------------------


# Get a list of TopModel result files
TopModelresults <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/ReTrainWithFP/gibbonNetRMulti3epoch/Selections/',
                              full.names = TRUE)

# Get a list of annotation selection table files
TestDataSet <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/AnnotatedFiles',
                          full.names = TRUE)

# Create an empty data frame to store TopModel detection results
TopModelDetectionDF <- data.frame()

# Loop through each TopModel result file
for (a in 1:length(TopModelresults)) {
  
  # Read the TopModel result table into a data frame
  TempTopModelTable <- read.delim2(TopModelresults[a])
  
  # Check if the data frame has rows
  if (nrow(TempTopModelTable) > 0) {
    
    # Extract the short name of the TopModel result file
    ShortName <- basename(TopModelresults[a])
    ShortName <- str_split_fixed(ShortName, pattern = '.wav', n = 2)[, 1]
    ShortName <- str_split_fixed(ShortName, pattern = '-__', n = 2)[, 2]
    
    # Find the corresponding annotation selection table
    testDataIndex <- which(str_detect(TestDataSet, ShortName))
    TestDataTable <- read.delim2(TestDataSet[testDataIndex])
    
    # Subset the annotation selection table to include only "LGFG" Call.Type
    #TestDataTable <- subset(TestDataTable, Call.Type == "LGFG")
    
    # Round Begin.Time..s. and End.Time..s. columns to numeric
    TestDataTable$Begin.Time..s. <- round(as.numeric(TestDataTable$Begin.Time..s.))
    TestDataTable$End.Time..s. <- round(as.numeric(TestDataTable$End.Time..s.))
    
    TopModelDetectionDFtemp <- data.frame()
    DetectionList <- list()
    # Loop through each row in TempTopModelTable
    for (c in 1:nrow(TempTopModelTable)) {
      TempRow <- TempTopModelTable[c,]
      
      # Check if Begin.Time..s. is not NA
      if (is.na(TempRow$Begin.Time..s.) == FALSE) {
        # Convert Begin.Time..s. and End.Time..s. to numeric
        TempRow$Begin.Time..s. <- as.numeric(TempRow$Begin.Time..s.)
        TempRow$End.Time..s. <- as.numeric(TempRow$End.Time..s.)
        
        # Determine if the time of the detection is within the time range of an annotation
        TimeBetween <- data.table::between(TempRow$Begin.Time..s.,
                                           TestDataTable$Begin.Time..s.-12,
                                           TestDataTable$End.Time..s.+12)
        
        # Extract the detection for which TimeBetween and TimeBetweenEnd are TRUE
        
        # For now focus only on start time
        
        TempDetection <- TestDataTable[  which(TimeBetween == TRUE), ]
        
        if (nrow(TempDetection) > 0) {
          # Set Class based on the Call.Type in TempDetection
          TempRow$Class <- TempDetection$Class[1]
          DetectionList[[length(DetectionList)+1]] <-  which(TimeBetween == TRUE)
        } else {
          # Set Class to 'Noise' if no corresponding annotation is found
          TempRow$Class <- 'Noise'
          # Uncomment the line below if you want to modify the Confidence value
          # TempRow$Confidence <- 1 - as.numeric(TempRow$Confidence)
        }
        
        # Set TrainingData to the basename of TopModel results directory
        #TempRow$TrainingData <- basename(TopModelresults[a])
        
        # Append TempRow to TopModelDetectionDF
        #TopModelDetectionDFtemp <- rbind.data.frame(TopModelDetectionDFtemp, TempRow)
        TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, TempRow)
      }
    }
  } 
  
  if(length(DetectionList) > 0){
  IndexMissed <-  TestDataTable[ -unlist(DetectionList),]
  if(nrow(IndexMissed) >0 ){
    
    IndexMissed <-   IndexMissed[,c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", 
                                    "Low.Freq..Hz.", "High.Freq..Hz.")]
    
    IndexMissed$Probability <- 0
    IndexMissed$Detections <- ShortName
    IndexMissed$Class <- 'CrestedGibbons'
    
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, IndexMissed)
    
  }  
  }
}

head(TopModelDetectionDF)
nrow(TopModelDetectionDF)

TotalSecondsDetectionsJahoo <- sum(TopModelDetectionDF$End.Time..s.-TopModelDetectionDF$Begin.Time..s.)

WavDur <- 60*60
clip_duration <- 12
hop_size <- 6

Seq.start <- list()
Seq.end <- list()

i <- 1
while (i + clip_duration < WavDur) {
  # print(i)
  Seq.start[[i]] = i
  Seq.end[[i]] = i+clip_duration
  i= i+hop_size
}


ClipStart <- unlist(Seq.start)
ClipEnd <- unlist(Seq.end)

TempClips <- cbind.data.frame(ClipStart,ClipEnd)


JahooAdj <-  nrow(TempClips)*length(TopModelresults) - length(TopModelresults)

# Convert Class column to a factor variable
TopModelDetectionDF$Class <- as.factor(TopModelDetectionDF$Class)

# Display unique values in the Class column
unique(TopModelDetectionDF$Class)

# Define a vector of confidence Thresholds
Thresholds <- seq(0,1,0.05)

# Create an empty data frame to store results
BestF1data.frameCrestedGibbonMulti <- data.frame()

# Loop through each threshold value
for(a in 1:length(Thresholds)){
  
  # Filter the subset based on the confidence threshold
  TopModelDetectionDF_single <-TopModelDetectionDF
  
  TopModelDetectionDF_single$PredictedClass <-  
    ifelse(TopModelDetectionDF_single$Probability  <=Thresholds[a], 'Noise','CrestedGibbons')
  
  # Calculate confusion matrix using caret package
  caretConf <- caret::confusionMatrix(
    as.factor(TopModelDetectionDF_single$PredictedClass),
    as.factor(TopModelDetectionDF_single$Class),
    mode = 'everything')
  
  
  # Extract F1 score, Precision, and Recall from the confusion matrix
  F1 <- caretConf$byClass[7]
  Precision <- caretConf$byClass[5]
  Recall <- caretConf$byClass[6]
  FP <- caretConf$table[1,2]
  TN <- caretConf$table[2,2]+JahooAdj
  FPR <-  FP / (FP + TN)
  # Create a row for the result and add it to the BestF1data.frameGreyGibbon
  #TrainingData <- training_data_type
  TempF1Row <- cbind.data.frame(F1, Precision, Recall,FPR)
  TempF1Row$Thresholds <- Thresholds[a]
  BestF1data.frameCrestedGibbonMulti <- rbind.data.frame(BestF1data.frameCrestedGibbonMulti, TempF1Row)
}

BestF1data.frameCrestedGibbonMulti



# Metric plot
CrestedGibbonMultiPlot <- ggplot(data = BestF1data.frameCrestedGibbonMulti, aes(x = Thresholds)) +
  geom_line(aes(y = F1, color = "F1", linetype = "F1")) +
  geom_line(aes(y = Precision, color = "Precision", linetype = "Precision")) +
  geom_line(aes(y = Recall, color = "Recall", linetype = "Recall")) +
  labs(title = "Crested Gibbons (multi)",
       x = "Confidence",
       y = "Values") +
  scale_color_manual(values = c("F1" = "blue", "Precision" = "red", "Recall" = "green"),
                     labels = c("F1", "Precision", "Recall")) +
  scale_linetype_manual(values = c("F1" = "dashed", "Precision" = "dotted", "Recall" = "solid")) +
  theme_minimal() +
  theme(legend.title = element_blank())+
  labs(color  = "Guide name", linetype = "Guide name", shape = "Guide name")

CrestedGibbonMultiPlot

