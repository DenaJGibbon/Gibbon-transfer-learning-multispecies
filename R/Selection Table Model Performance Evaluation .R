# Load necessary libraries
library(stringr)  # For string manipulation
library(caret)    # For machine learning and model evaluation
library(ggpubr)   # For data visualization
library(dplyr)    # For data manipulation
library(data.table) # For sorting the detections

# NOTE you need to change the file paths below to where your files are located on your computer


# KSWS Performance --------------------------------------------------------

# Get a list of TopModel result files
TopModelresults <- list.files('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/WideArrayEvaluation/KSWSEvaluation/gibbonNetRoutput/Selections/',
                             full.names = TRUE)

# Get a list of annotation selection table files
TestDataSet <- list.files('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/WideArrayEvaluation/KSWSEvaluation/AnnotatedFiles',
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
                                             TestDataTable$Begin.Time..s.-3,
                                             TestDataTable$End.Time..s.+3)
           
          # Extract the detection for which TimeBetween and TimeBetweenEnd are TRUE
         
          # For now focus only on start time
           
          TempDetection <- TestDataTable[  which(TimeBetween == TRUE), ]
          
          if (nrow(TempDetection) > 0) {
            # Set Class based on the Call.Type in TempDetection
            TempRow$Class <- TempDetection$Class
          } else {
            # Set Class to 'Noise' if no corresponding annotation is found
            TempRow$Class <- 'Noise'
            # Uncomment the line below if you want to modify the Confidence value
            # TempRow$Confidence <- 1 - as.numeric(TempRow$Confidence)
          }
          
          # Set TrainingData to the basename of TopModel results directory
          #TempRow$TrainingData <- basename(TopModelresults[a])
          
          # Append TempRow to TopModelDetectionDF
          TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, TempRow)
        }
      }
    }
  }


# Convert Class column to a factor variable
TopModelDetectionDF$Class <- as.factor(TopModelDetectionDF$Class)

# Display unique values in the Class column
unique(TopModelDetectionDF$Class)

# Define a vector of confidence thresholds
thresholds <- c(.5, .75, .85, .9, .95)

# Create an empty data frame to store results
BestF1data.frameCrestedGibbon <- data.frame()

# Loop through each threshold value
for(a in 1:length(thresholds)){
  
  # Filter the subset based on the confidence threshold
  TopModelDetectionDF_single <-TopModelDetectionDF
  
  TopModelDetectionDF_single$PredictedClass <-  ifelse(TopModelDetectionDF_single$Probability  < thresholds[a], 'Noise','CrestedGibbons')
  
    # Calculate confusion matrix using caret package
    caretConf <- caret::confusionMatrix(
      as.factor(TopModelDetectionDF_single$PredictedClass),
      as.factor(TopModelDetectionDF_single$Class),
      mode = 'everything')
    
    # Extract F1 score, Precision, and Recall from the confusion matrix
    F1caret <- caretConf$byClass[7]
    Precisioncaret <- caretConf$byClass[5]
    Recallcaret <- caretConf$byClass[6]
    
    # Create a row for the result and add it to the BestF1data.frameCrestedGibbon
    #TrainingData <- training_data_type
    TempF1Row <- cbind.data.frame(F1caret, Precisioncaret, Recallcaret)
    TempF1Row$thresholds <- thresholds[a]
    BestF1data.frameCrestedGibbon <- rbind.data.frame(BestF1data.frameCrestedGibbon, TempF1Row)
  }

BestF1data.frameCrestedGibbon


# Create a line plot for F1 score vs. TrainingData, faceted by thresholds
ggline(data = BestF1data.frameCrestedGibbon, x = 'thresholds', y = 'F1caret')


# Danum Array Evaluation --------------------------------------------------
# Get a list of TopModel result files
TopModelresults <- list.files('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutput/Selections/',
                              full.names = TRUE)

# Get a list of annotation selection table files
TestDataSet <- list.files('/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/AnnotatedFiles',
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
    TestDataTable <- subset(TestDataTable,Call.type=='female.gibbon')
    # Subset the annotation selection table to include only "LGFG" Call.Type
    #TestDataTable <- subset(TestDataTable, Call.Type == "LGFG")
    
    # Round Begin.Time..s. and End.Time..s. columns to numeric
    TestDataTable$Begin.Time..s. <- round(as.numeric(TestDataTable$Begin.Time..s.))
    TestDataTable$End.Time..s. <- round(as.numeric(TestDataTable$End.Time..s.))
    
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
                                           TestDataTable$Begin.Time..s.-4,
                                           TestDataTable$End.Time..s.+4)
        
        # Extract the detection for which TimeBetween and TimeBetweenEnd are TRUE
        
        # For now focus only on start time
        
        TempDetection <- TestDataTable[  which(TimeBetween == TRUE), ]
        
        if (nrow(TempDetection) > 0) {
          # Set Class based on the Call.Type in TempDetection
          TempRow$Class <- 'GreyGibbons'
        } else {
          # Set Class to 'Noise' if no corresponding annotation is found
          TempRow$Class <- 'Noise'
          # Uncomment the line below if you want to modify the Confidence value
          # TempRow$Confidence <- 1 - as.numeric(TempRow$Confidence)
        }
        
        # Set TrainingData to the basename of TopModel results directory
        #TempRow$TrainingData <- basename(TopModelresults[a])
        
        # Append TempRow to TopModelDetectionDF
        TopModelDetectionDF <- rbind.data.frame(TopModelDetectionDF, TempRow)
      }
    }
  }
}


# Convert Class column to a factor variable
TopModelDetectionDF$Class <- as.factor(TopModelDetectionDF$Class)

# Display unique values in the Class column
unique(TopModelDetectionDF$Class)

# Define a vector of confidence thresholds
thresholds <- c(.5, .75, .85, .9, .95)

# Create an empty data frame to store results
BestF1data.frameGreyGibbon <- data.frame()

# Loop through each threshold value
for(a in 1:length(thresholds)){
  
  # Filter the subset based on the confidence threshold
  TopModelDetectionDF_single <-TopModelDetectionDF
  
  TopModelDetectionDF_single$PredictedClass <-  ifelse(TopModelDetectionDF_single$Probability  < thresholds[a], 'Noise','GreyGibbons')
  
  # Calculate confusion matrix using caret package
  caretConf <- caret::confusionMatrix(
    as.factor(TopModelDetectionDF_single$PredictedClass),
    as.factor(TopModelDetectionDF_single$Class),
    mode = 'everything')
  
  # Extract F1 score, Precision, and Recall from the confusion matrix
  F1caret <- caretConf$byClass[7]
  Precisioncaret <- caretConf$byClass[5]
  Recallcaret <- caretConf$byClass[6]
  
  # Create a row for the result and add it to the BestF1data.frameGreyGibbon
  #TrainingData <- training_data_type
  TempF1Row <- cbind.data.frame(F1caret, Precisioncaret, Recallcaret)
  TempF1Row$thresholds <- thresholds[a]
  BestF1data.frameGreyGibbon <- rbind.data.frame(BestF1data.frameGreyGibbon, TempF1Row)
}

BestF1data.frameCrestedGibbon


BestF1data.frameGreyGibbon




