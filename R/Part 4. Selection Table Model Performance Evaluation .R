# Load necessary libraries
library(stringr)  # For string manipulation
library(caret)    # For machine learning and model evaluation
library(ggpubr)   # For data visualization
library(dplyr)    # For data manipulation
library(data.table) # For sorting the detections
library(ggplot2)

# NOTE you need to change the file paths below to where your files are located on your computer

# KSWS Performance Binary --------------------------------------------------------

# Get a list of TopModel result files
TopModelresults <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRoutputFinal/Selections/',
                             full.names = TRUE)

# Get a list of annotation selection table files
TestDataSet <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/AnnotatedFiles',
                          full.names = TRUE)

# Preallocate space for TopModelDetectionDF
TopModelDetectionDF <- data.frame()

# Loop through each TopModel result file
for (a in 1:length(TopModelresults)) {
  
  # Read the TopModel result table into a data frame
  TempTopModelTable <- read.delim2(TopModelresults[a])
  
  # Extract the short name of the TopModel result file
  ShortName <- basename(TopModelresults[a])
  ShortName <- str_split_fixed(ShortName, pattern = '.wav', n = 2)[, 1]
  ShortName <- str_split_fixed(ShortName, pattern = '-__', n = 2)[, 2]
  
  # Find the corresponding annotation selection table
  testDataIndex <- which(str_detect(TestDataSet, ShortName))
  TestDataTable <- read.delim2(TestDataSet[testDataIndex])
  
  
  # Round Begin.Time..s. and End.Time..s. columns to numeric
  TestDataTable$Begin.Time..s. <- round(as.numeric(TestDataTable$Begin.Time..s.))
  TestDataTable$End.Time..s. <- round(as.numeric(TestDataTable$End.Time..s.))
  
  DetectionList <- list()
  # Loop through each row in TempTopModelTable
  for (c in 1:nrow(TempTopModelTable)) {
    TempRow <- TempTopModelTable[c,]
    
    # Check if Begin.Time..s. is not NA
    if (!is.na(TempRow$Begin.Time..s.)) {
      # Convert Begin.Time..s. and End.Time..s. to numeric
      TempRow$Begin.Time..s. <- as.numeric(TempRow$Begin.Time..s.)
      TempRow$End.Time..s. <- as.numeric(TempRow$End.Time..s.)
      
      # Determine if the time of the detection is within the time range of an annotation
      TimeBetween <- data.table::between(TempRow$Begin.Time..s.,
                                         TestDataTable$Begin.Time..s. - 12,
                                         TestDataTable$Begin.Time..s. + 12)
      
      # Extract the detections matching the time range
      matched_detections <- TestDataTable[TimeBetween, ]
      
      if (nrow(matched_detections) > 0) {
        # Set Class based on the Call.Type in matched_detections
        TempRow$Class <- 'CrestedGibbon'
        DetectionList[[length( unlist(DetectionList))+1]] <-  which(TimeBetween == TRUE)
      } else {
        # Set Class to 'Noise' if no corresponding annotation is found
        TempRow$Class <- 'Noise'
      }
      
      # Append TempRow to TopModelDetectionDF
      TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, TempRow)
    }
  }
  
  # Identify missed detections
 
  
  if (length( unlist(DetectionList)) > 0 &  length( unlist(DetectionList)) < nrow(TestDataTable) ) {
    
    missed_detections <- TestDataTable[-unlist(DetectionList), ]
    # Prepare missed detections data
    missed_detections <- missed_detections[, c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", "Low.Freq..Hz.", "High.Freq..Hz.")]
    missed_detections$Probability <- 0
    missed_detections$Detections <- ShortName
    missed_detections$Class <- 'CrestedGibbon'
    
    # Append missed detections to TopModelDetectionDF
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, missed_detections)
  }
  
  if (length( unlist(DetectionList)) == 0) {
    
    missed_detections <- TestDataTable
    # Prepare missed detections data
    missed_detections <- missed_detections[, c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", "Low.Freq..Hz.", "High.Freq..Hz.")]
    missed_detections$Probability <- 0
    missed_detections$Detections <- ShortName
    missed_detections$Class <- 'CrestedGibbon'
    
    # Append missed detections to TopModelDetectionDF
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, missed_detections)
    
  }
  
}

head(TopModelDetectionDF)
nrow(TopModelDetectionDF)
table(TopModelDetectionDF$Class)



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
Thresholds <-seq(0.1,1,0.1)

# Create an empty data frame to store results
BestF1data.frameCrestedGibbonBinary <- data.frame()

# Loop through each threshold value
for(a in 1:length(Thresholds)){
  
  # Filter the subset based on the confidence threshold
  TopModelDetectionDF_single <-TopModelDetectionDF
  
  TopModelDetectionDF_single$PredictedClass <-  
    ifelse(TopModelDetectionDF_single$Probability  <=Thresholds[a], 'Noise','CrestedGibbon')
  
    # Calculate confusion matrix using caret package
    caretConf <- caret::confusionMatrix(
      as.factor(TopModelDetectionDF_single$PredictedClass),
      as.factor(TopModelDetectionDF_single$Class),positive = 'CrestedGibbon',
      mode = 'everything')
    

    # Extract F1 score, Precision, and Recall from the confusion matrix
    F1 <- caretConf$byClass[7]
    Precision <- caretConf$byClass[5]
    Recall <- caretConf$byClass[6]
    FP <- caretConf$table[1,2]
    TN <- sum(caretConf$table[2,])#+JahooAdj
    FPR <-  FP / (FP + TN)
    # Create a row for the result and add it to the BestF1data.frameGreyGibbon
    #TrainingData <- training_data_type
    TempF1Row <- cbind.data.frame(F1, Precision, Recall,FPR)
    TempF1Row$Thresholds <- Thresholds[a]
    BestF1data.frameCrestedGibbonBinary <- rbind.data.frame(BestF1data.frameCrestedGibbonBinary, TempF1Row)
  }

BestF1data.frameCrestedGibbonBinary

CrestedGibbonMax <- round(max(na.omit(BestF1data.frameCrestedGibbonBinary$F1)),2)

# Metric plot
CrestedGibbonBinaryPlot <- ggplot(data = BestF1data.frameCrestedGibbonBinary, aes(x = Thresholds)) +
  geom_line(aes(y = F1, color = "F1", linetype = "F1")) +
  geom_line(aes(y = Precision, color = "Precision", linetype = "Precision")) +
  geom_line(aes(y = Recall, color = "Recall", linetype = "Recall")) +
  labs(title = paste("Crested Gibbons (binary) \n max F1:",CrestedGibbonMax),
       x = "Confidence",
       y = "Values") +
  scale_color_manual(values = c("F1" = "blue", "Precision" = "red", "Recall" = "green"),
                     labels = c("F1", "Precision", "Recall")) +
  scale_linetype_manual(values = c("F1" = "dashed", "Precision" = "dotted", "Recall" = "solid")) +
  theme_minimal() +
  theme(legend.title = element_blank())+
  labs(color  = "Guide name", linetype = "Guide name", shape = "Guide name")

CrestedGibbonBinaryPlot

# Danum Binary --------------------------------------------------
# Get a list of TopModel result files
TopModelresults <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutputFinal/Selections/',
                              full.names = TRUE)

# Get a list of annotation selection table files
TestDataSet <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/AnnotatedFiles/',
                          full.names = TRUE)


# Preallocate space for TopModelDetectionDF
TopModelDetectionDF <- data.frame()

# Loop through each TopModel result file
for (a in 1:length(TopModelresults)) {
  
  # Read the TopModel result table into a data frame
  TempTopModelTable <- read.delim2(TopModelresults[a])
  
  # Extract the short name of the TopModel result file
  ShortName <- basename(TopModelresults[a])
  ShortName <- str_split_fixed(ShortName, pattern = '.wav', n = 2)[, 1]
  ShortName <- str_split_fixed(ShortName, pattern = '-__', n = 2)[, 2]
  
  # Find the corresponding annotation selection table
  testDataIndex <- which(str_detect(TestDataSet, ShortName))
  TestDataTable <- read.delim2(TestDataSet[testDataIndex])
  
  # Subset the annotation selection table to include only "LGFG" Call.Type
  TestDataTable <- subset(TestDataTable, Call.type == "female.gibbon")
  
  # Round Begin.Time..s. and End.Time..s. columns to numeric
  TestDataTable$Begin.Time..s. <- round(as.numeric(TestDataTable$Begin.Time..s.))
  TestDataTable$End.Time..s. <- round(as.numeric(TestDataTable$End.Time..s.))
  
  DetectionList <- list()
  # Loop through each row in TempTopModelTable
  for (c in 1:nrow(TempTopModelTable)) {
    TempRow <- TempTopModelTable[c,]
    
    # Check if Begin.Time..s. is not NA
    if (!is.na(TempRow$Begin.Time..s.)) {
      # Convert Begin.Time..s. and End.Time..s. to numeric
      TempRow$Begin.Time..s. <- as.numeric(TempRow$Begin.Time..s.)
      TempRow$End.Time..s. <- as.numeric(TempRow$End.Time..s.)
      
      # Determine if the time of the detection is within the time range of an annotation
      TimeBetween <- data.table::between(TempRow$Begin.Time..s.,
                                         TestDataTable$Begin.Time..s. - 12,
                                         TestDataTable$Begin.Time..s. + 12)
      
      # Extract the detections matching the time range
      matched_detections <- TestDataTable[TimeBetween, ]
      
      if (nrow(matched_detections) > 0) {
        # Set Class based on the Call.Type in matched_detections
        TempRow$Class <- 'GreyGibbon'
        DetectionList[[length( unlist(DetectionList))+1]] <-  which(TimeBetween == TRUE)
      } else {
        # Set Class to 'Noise' if no corresponding annotation is found
        TempRow$Class <- 'Noise'
      }
      
      # Append TempRow to TopModelDetectionDF
      TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, TempRow)
    }
  }
  
  if (length( unlist(DetectionList)) > 0 &  length( unlist(DetectionList)) < nrow(TestDataTable) ) {
    
    missed_detections <- TestDataTable[-unlist(DetectionList), ]
    # Prepare missed detections data
    missed_detections <- missed_detections[, c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", "Low.Freq..Hz.", "High.Freq..Hz.")]
    missed_detections$Probability <- 0
    missed_detections$Detections <- ShortName
    missed_detections$Class <- 'GreyGibbon'
    
    # Append missed detections to TopModelDetectionDF
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, missed_detections)
  } 
  
  if (length( unlist(DetectionList)) == 0) {
    
    missed_detections <- TestDataTable
    # Prepare missed detections data
    missed_detections <- missed_detections[, c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", "Low.Freq..Hz.", "High.Freq..Hz.")]
    missed_detections$Probability <- 0
    missed_detections$Detections <- ShortName
    missed_detections$Class <- 'GreyGibbon'
    
    # Append missed detections to TopModelDetectionDF
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, missed_detections)
    
  }
  
}


WavDur <- 7200
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

DanumAdj <-  nrow(TempClips)*length(TopModelresults) - nrow(TopModelDetectionDF)

# Convert Class column to a factor variable
TopModelDetectionDF$Class <- as.factor(TopModelDetectionDF$Class)

# Display unique values in the Class column
unique(TopModelDetectionDF$Class)

# Define a vector of confidence Thresholds
Thresholds <-seq(0.1,1,0.1)

# Create an empty data frame to store results
BestF1data.frameGreyGibbonBinary <- data.frame()

# Loop through each threshold value
for(a in 1:length(Thresholds)){
  
  # Filter the subset based on the confidence threshold
  TopModelDetectionDF_single <-TopModelDetectionDF
  
  TopModelDetectionDF_single$PredictedClass <-  ifelse(TopModelDetectionDF_single$Probability  < Thresholds[a], 'Noise','GreyGibbon')
  
  # Calculate confusion matrix using caret package
  caretConf <- caret::confusionMatrix(
    as.factor(TopModelDetectionDF_single$PredictedClass),
    as.factor(TopModelDetectionDF_single$Class),positive='GreyGibbon',
    mode = 'everything')
  
  false_positives <- caretConf$table[1,2]
  true_negatives <- caretConf$table[2,2]
  
  FPR <- false_positives / (false_positives + true_negatives)
  
  # Extract F1 score, Precision, and Recall from the confusion matrix
  F1 <- caretConf$byClass[7]
  Precision <- caretConf$byClass[5]
  Recall <- caretConf$byClass[6]

  FP <- caretConf$table[1,1]
  TN <- sum(caretConf$table[2,])#+DanumAdj
  
  
  FPR <-  FP / (FP + TN)
  # Create a row for the result and add it to the BestF1data.frameGreyGibbonBinary
  #TrainingData <- training_data_type
  TempF1Row <- cbind.data.frame(F1, Precision, Recall,FPR)
  TempF1Row$Thresholds <- Thresholds[a]
  BestF1data.frameGreyGibbonBinary <- rbind.data.frame(BestF1data.frameGreyGibbonBinary, TempF1Row)
}


BestF1data.frameGreyGibbonBinary

GreyGibbonMax <- round(max(na.omit(BestF1data.frameGreyGibbonBinary$F1)),2)

# Metric plot
GreyGibbonBinaryPlot <- ggplot(data = BestF1data.frameGreyGibbonBinary, aes(x = Thresholds)) +
  geom_line(aes(y = F1, color = "F1", linetype = "F1")) +
  geom_line(aes(y = Precision, color = "Precision", linetype = "Precision")) +
  geom_line(aes(y = Recall, color = "Recall", linetype = "Recall")) +
  labs(title = paste("Grey Gibbons (binary) \n max F1:",GreyGibbonMax),
       x = "Confidence",
       y = "Values") +
  scale_color_manual(values = c("F1" = "blue", "Precision" = "red", "Recall" = "green"),
                     labels = c("F1", "Precision", "Recall")) +
  scale_linetype_manual(values = c("F1" = "dashed", "Precision" = "dotted", "Recall" = "solid")) +
  theme_minimal() +
  theme(legend.title = element_blank())+
  labs(color  = "Guide name", linetype = "Guide name", shape = "Guide name")

GreyGibbonBinaryPlot

# Multi-class  ------------------------------------------------------------

# KSWS Performance --------------------------------------------------------

# Get a list of TopModel result files
TopModelresults <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRMultiFinal/Selections/',
                              full.names = TRUE)

# Get a list of annotation selection table files
TestDataSet <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/AnnotatedFiles',
                          full.names = TRUE)

# Preallocate space for TopModelDetectionDF
TopModelDetectionDF <- data.frame()

# Loop through each TopModel result file
for (a in 1:length(TopModelresults)) {
  
  # Read the TopModel result table into a data frame
  TempTopModelTable <- read.delim2(TopModelresults[a])
  
  # Extract the short name of the TopModel result file
  ShortName <- basename(TopModelresults[a])
  ShortName <- str_split_fixed(ShortName, pattern = '.wav', n = 2)[, 1]
  ShortName <- str_split_fixed(ShortName, pattern = '-__', n = 2)[, 2]
  
  # Find the corresponding annotation selection table
  testDataIndex <- which(str_detect(TestDataSet, ShortName))
  TestDataTable <- read.delim2(TestDataSet[testDataIndex])
  
  
  # Round Begin.Time..s. and End.Time..s. columns to numeric
  TestDataTable$Begin.Time..s. <- round(as.numeric(TestDataTable$Begin.Time..s.))
  TestDataTable$End.Time..s. <- round(as.numeric(TestDataTable$End.Time..s.))
  
  DetectionList <- list()
  # Loop through each row in TempTopModelTable
  for (c in 1:nrow(TempTopModelTable)) {
    TempRow <- TempTopModelTable[c,]
    
    # Check if Begin.Time..s. is not NA
    if (!is.na(TempRow$Begin.Time..s.)) {
      # Convert Begin.Time..s. and End.Time..s. to numeric
      TempRow$Begin.Time..s. <- as.numeric(TempRow$Begin.Time..s.)
      TempRow$End.Time..s. <- as.numeric(TempRow$End.Time..s.)
      
      # Determine if the time of the detection is within the time range of an annotation
      TimeBetween <- data.table::between(TempRow$Begin.Time..s.,
                                         TestDataTable$Begin.Time..s. - 12,
                                         TestDataTable$Begin.Time..s. + 12)
      
      # Extract the detections matching the time range
      matched_detections <- TestDataTable[TimeBetween, ]
      
      if (nrow(matched_detections) > 0) {
        # Set Class based on the Call.Type in matched_detections
        TempRow$Class <- 'CrestedGibbon'
        DetectionList[[length( unlist(DetectionList))+1]] <-  which(TimeBetween == TRUE)
      } else {
        # Set Class to 'Noise' if no corresponding annotation is found
        TempRow$Class <- 'Noise'
      }
      
      # Append TempRow to TopModelDetectionDF
      TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, TempRow)
    }
  }
  
  if (length( unlist(DetectionList)) > 0 &  length( unlist(DetectionList)) < nrow(TestDataTable) ) {
    
    missed_detections <- TestDataTable[-unlist(DetectionList), ]
    # Prepare missed detections data
    missed_detections <- missed_detections[, c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", "Low.Freq..Hz.", "High.Freq..Hz.")]
    missed_detections$Probability <- 0
    missed_detections$Detections <- ShortName
    missed_detections$Class <- 'CrestedGibbon'
    
    # Append missed detections to TopModelDetectionDF
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, missed_detections)
  } 
  
  if (length( unlist(DetectionList)) == 0) {
    
    missed_detections <- TestDataTable
    # Prepare missed detections data
    missed_detections <- missed_detections[, c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", "Low.Freq..Hz.", "High.Freq..Hz.")]
    missed_detections$Probability <- 0
    missed_detections$Detections <- ShortName
    missed_detections$Class <- 'CrestedGibbon'
    
    # Append missed detections to TopModelDetectionDF
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, missed_detections)
    
  }
  
}


table(TopModelDetectionDF$Class)
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

TopModelDetectionDF$Probability <- as.numeric(TopModelDetectionDF$Probability)

# Display unique values in the Class column
unique(TopModelDetectionDF$Class)

# Define a vector of confidence Thresholds
Thresholds <-seq(0.1,1,0.1)

# Create an empty data frame to store results
BestF1data.frameCrestedGibbonMulti <- data.frame()

# Loop through each threshold value
for(a in 1:length(Thresholds)){
  
  # Filter the subset based on the confidence threshold
  TopModelDetectionDF_single <-TopModelDetectionDF
  
  TopModelDetectionDF_single$PredictedClass <-  
    ifelse(TopModelDetectionDF_single$Probability  <=Thresholds[a], 'Noise','CrestedGibbon')
  
  # Calculate confusion matrix using caret package
  caretConf <- caret::confusionMatrix(
    as.factor(TopModelDetectionDF_single$PredictedClass),
    as.factor(TopModelDetectionDF_single$Class),positive = 'CrestedGibbon',
    mode = 'everything')
  
  
  # Extract F1 score, Precision, and Recall from the confusion matrix
  F1 <- caretConf$byClass[7]
  Precision <- caretConf$byClass[5]
  Recall <- caretConf$byClass[6]
  FP <- caretConf$table[1,2]
  TN <- sum(caretConf$table[2,])#+JahooAdj
  FPR <-  FP / (FP + TN)
  # Create a row for the result and add it to the BestF1data.frameGreyGibbon
  #TrainingData <- training_data_type
  TempF1Row <- cbind.data.frame(F1, Precision, Recall,FPR)
  TempF1Row$Thresholds <- Thresholds[a]
  BestF1data.frameCrestedGibbonMulti <- rbind.data.frame(BestF1data.frameCrestedGibbonMulti, TempF1Row)
}

BestF1data.frameCrestedGibbonMulti



CrestedGibbonMultiMax <- round(max(na.omit(BestF1data.frameCrestedGibbonMulti$F1)),2)

# Metric plot
CrestedGibbonMultiPlot <- ggplot(data = BestF1data.frameCrestedGibbonMulti, aes(x = Thresholds)) +
  geom_line(aes(y = F1, color = "F1", linetype = "F1")) +
  geom_line(aes(y = Precision, color = "Precision", linetype = "Precision")) +
  geom_line(aes(y = Recall, color = "Recall", linetype = "Recall")) +
  labs(title = paste("Crested Gibbons (multi) \n F1:", CrestedGibbonMultiMax),
       x = "Confidence",
       y = "Values") +
  scale_color_manual(values = c("F1" = "blue", "Precision" = "red", "Recall" = "green"),
                     labels = c("F1", "Precision", "Recall")) +
  scale_linetype_manual(values = c("F1" = "dashed", "Precision" = "dotted", "Recall" = "solid")) +
  theme_minimal() +
  theme(legend.title = element_blank())+
  labs(color  = "Guide name", linetype = "Guide name", shape = "Guide name")

CrestedGibbonMultiPlot

# Danum Multi --------------------------------------------------------

# Get a list of TopModel result files
TopModelresults <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRMultiFinal/Selections/',
                              full.names = TRUE)

# Get a list of annotation selection table files
TestDataSet <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/AnnotatedFiles/',
                          full.names = TRUE)

# Preallocate space for TopModelDetectionDF
TopModelDetectionDF <- data.frame()

# Loop through each TopModel result file
for (a in 1:length(TopModelresults)) {
  
  # Read the TopModel result table into a data frame
  TempTopModelTable <- read.delim2(TopModelresults[a])
  
  # Extract the short name of the TopModel result file
  ShortName <- basename(TopModelresults[a])
  ShortName <- str_split_fixed(ShortName, pattern = '.wav', n = 2)[, 1]
  ShortName <- str_split_fixed(ShortName, pattern = '-__', n = 2)[, 2]
  
  # Find the corresponding annotation selection table
  testDataIndex <- which(str_detect(TestDataSet, ShortName))
  TestDataTable <- read.delim2(TestDataSet[testDataIndex])
  
  # Subset the annotation selection table to include only "LGFG" Call.Type
  TestDataTable <- subset(TestDataTable, Call.type == "female.gibbon")
  
  # Round Begin.Time..s. and End.Time..s. columns to numeric
  TestDataTable$Begin.Time..s. <- round(as.numeric(TestDataTable$Begin.Time..s.))
  TestDataTable$End.Time..s. <- round(as.numeric(TestDataTable$End.Time..s.))
  
  DetectionList <- list()
  # Loop through each row in TempTopModelTable
  for (c in 1:nrow(TempTopModelTable)) {
    TempRow <- TempTopModelTable[c,]
    
    # Check if Begin.Time..s. is not NA
    if (!is.na(TempRow$Begin.Time..s.)) {
      # Convert Begin.Time..s. and End.Time..s. to numeric
      TempRow$Begin.Time..s. <- as.numeric(TempRow$Begin.Time..s.)
      TempRow$End.Time..s. <- as.numeric(TempRow$End.Time..s.)
      
      # Determine if the time of the detection is within the time range of an annotation
      TimeBetween <- data.table::between(TempRow$Begin.Time..s.,
                                         TestDataTable$Begin.Time..s. - 12,
                                         TestDataTable$Begin.Time..s. + 12)
      
      # Extract the detections matching the time range
      matched_detections <- TestDataTable[TimeBetween, ]
      
      if (nrow(matched_detections) > 0) {
        # Set Class based on the Call.Type in matched_detections
        TempRow$Class <- 'GreyGibbon'
        DetectionList[[length( unlist(DetectionList))+1]] <-  which(TimeBetween == TRUE)
      } else {
        # Set Class to 'Noise' if no corresponding annotation is found
        TempRow$Class <- 'Noise'
      }
      
      # Append TempRow to TopModelDetectionDF
      TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, TempRow)
    }
  }
  
  if (length( unlist(DetectionList)) > 0 &  length( unlist(DetectionList)) < nrow(TestDataTable) ) {
    
    missed_detections <- TestDataTable[-unlist(DetectionList), ]
    # Prepare missed detections data
    missed_detections <- missed_detections[, c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", "Low.Freq..Hz.", "High.Freq..Hz.")]
    missed_detections$Probability <- 0
    missed_detections$Detections <- ShortName
    missed_detections$Class <- 'GreyGibbon'
    
    # Append missed detections to TopModelDetectionDF
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, missed_detections)
  }
  
  if (length( unlist(DetectionList)) == 0) {
    
    missed_detections <- TestDataTable
    # Prepare missed detections data
    missed_detections <- missed_detections[, c("Selection", "View", "Channel", "Begin.Time..s.", "End.Time..s.", "Low.Freq..Hz.", "High.Freq..Hz.")]
    missed_detections$Probability <- 0
    missed_detections$Detections <- ShortName
    missed_detections$Class <- 'GreyGibbon'
    
    # Append missed detections to TopModelDetectionDF
    TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, missed_detections)
    
  }
  
}

head(TopModelDetectionDF)
nrow(TopModelDetectionDF)

table(TopModelDetectionDF$Class)

TotalSecondsDetectionsDanumValley <- sum(TopModelDetectionDF$End.Time..s.-TopModelDetectionDF$Begin.Time..s.)

WavDur <- 7200
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


DanumValleyAdj <-  nrow(TempClips)*length(TopModelresults) - length(TopModelresults)

# Convert Class column to a factor variable
TopModelDetectionDF$Class <- as.factor(TopModelDetectionDF$Class)

# Display unique values in the Class column
unique(TopModelDetectionDF$Class)

# Define a vector of confidence Thresholds
Thresholds <-seq(0.1,1,0.1)

# Create an empty data frame to store results
BestF1data.frameGreyGibbonMulti <- data.frame()

# Loop through each threshold value
for(a in 1:length(Thresholds)){
  
  # Filter the subset based on the confidence threshold
  TopModelDetectionDF_single <-TopModelDetectionDF
  
  TopModelDetectionDF_single$PredictedClass <-  
    ifelse(TopModelDetectionDF_single$Probability  <=Thresholds[a], 'Noise','GreyGibbon')
  
  # Calculate confusion matrix using caret package
  caretConf <- caret::confusionMatrix(
    as.factor(TopModelDetectionDF_single$PredictedClass),
    as.factor(TopModelDetectionDF_single$Class),#positive = 'GreyGibbon',
    mode = 'everything')
  
  
  # Extract F1 score, Precision, and Recall from the confusion matrix
  F1 <- caretConf$byClass[7]
  Precision <- caretConf$byClass[5]
  Recall <- caretConf$byClass[6]
  FP <- caretConf$table[1,2]
  TN <- sum(caretConf$table[2,])#+DanumValleyAdj
  FPR <-  FP / (FP + TN)
  
  # Create a row for the result and add it to the BestF1data.frameGreyGibbon
  #TrainingData <- training_data_type
  TempF1Row <- cbind.data.frame(F1, Precision, Recall,FPR)
  TempF1Row$Thresholds <- Thresholds[a]
  BestF1data.frameGreyGibbonMulti <- rbind.data.frame(BestF1data.frameGreyGibbonMulti, TempF1Row)
}

BestF1data.frameGreyGibbonMulti

GreyGibbonMultiMax <- round(max(na.omit(BestF1data.frameGreyGibbonMulti$F1)),2)

# Metric plot
GreyGibbonMultiPlot <- ggplot(data = BestF1data.frameGreyGibbonMulti, aes(x = Thresholds)) +
  geom_line(aes(y = F1, color = "F1", linetype = "F1")) +
  geom_line(aes(y = Precision, color = "Precision", linetype = "Precision")) +
  geom_line(aes(y = Recall, color = "Recall", linetype = "Recall")) +
  labs(title = paste("Grey Gibbons (multi) \n F1:", GreyGibbonMultiMax),
       x = "Confidence",
       y = "Values") +
  scale_color_manual(values = c("F1" = "blue", "Precision" = "red", "Recall" = "green"),
                     labels = c("F1", "Precision", "Recall")) +
  scale_linetype_manual(values = c("F1" = "dashed", "Precision" = "dotted", "Recall" = "solid")) +
  theme_minimal() +
  theme(legend.title = element_blank())+
  labs(color  = "Guide name", linetype = "Guide name", shape = "Guide name")

GreyGibbonMultiPlot


# Combine plots -----------------------------------------------------------

cowplot::plot_grid(CrestedGibbonBinaryPlot,GreyGibbonBinaryPlot,
                   CrestedGibbonMultiPlot,GreyGibbonMultiPlot,
                   labels=c('A)','B)','C)', 'D)'), label_x = 0.9)

# Combined performance dataframe ------------------------------------------


CombinedPerformance <- 
  rbind.data.frame(BestF1data.frameCrestedGibbonBinary[which.max(BestF1data.frameCrestedGibbonBinary$F1),],
                   BestF1data.frameGreyGibbonBinary[which.max(BestF1data.frameGreyGibbonBinary$F1),],
                   BestF1data.frameCrestedGibbonMulti[which.max(BestF1data.frameCrestedGibbonMulti$F1),],
                    BestF1data.frameGreyGibbonMulti[which.max(BestF1data.frameGreyGibbonMulti$F1),])

Species <- c('Crested Gibbon (binary)', 'Grey Gibbon (binary)',
             'Crested Gibbon (multi)', 'Grey Gibbon (multi)')

CombinedPerformance <- cbind(Species,CombinedPerformance)
CombinedPerformance

CombinedPerformance <- CombinedPerformance %>% mutate_if(is.numeric, ~round(., 2))

#CombinedPerformance$FPR[1] <- 0.01
CombinedPerformance$Architecture <- c('ResNet50','VGG19','ResNet50','ResNet50')

CombinedPerformance <- CombinedPerformance[,c("Species","Architecture", "F1", "Precision", "Recall", "FPR", "Thresholds")]

CombinedPerformanceFlex <- flextable::flextable(CombinedPerformance)
CombinedPerformanceFlex

flextable::save_as_docx(CombinedPerformanceFlex,path='tables/Table 4. Performance.docx')



# Sample size calculation -------------------------------------------------

# Get a list of annotation selection table files
TestDataSetDanum <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/AnnotatedFiles/',
                          full.names = TRUE)

TestDataSetDanum <- lapply(TestDataSetDanum,read.delim2)

GibbonDanumList <- list()
for(a in 1:length(TestDataSetDanum)){
  
  TempTable <- TestDataSetDanum[[a]]
  TempTable <- subset(TempTable,Call.type=='female.gibbon')
  GibbonDanumList[[a]] <- nrow(TempTable)
}

sum(unlist(GibbonDanumList))

# Get a list of annotation selection table files
TestDataSetJahoo <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/AnnotatedFiles',
                               full.names = TRUE)

TestDataSetJahoo <- lapply(TestDataSetJahoo,read.delim2)

GibbonJahooList <- list()
for(a in 1:length(TestDataSetJahoo)){
  
  TempTable <- TestDataSetJahoo[[a]]
  TempTable <- subset(TempTable,Class=='CrestedGibbons')
  GibbonJahooList[[a]] <- nrow(TempTable)
}

sum(unlist(GibbonJahooList))


