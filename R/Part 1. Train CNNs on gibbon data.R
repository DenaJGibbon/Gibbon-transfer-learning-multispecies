# Load libraries -------------------------------------------------------------------------
library(dplyr)
library(flextable)
library(dplyr)
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

# Optional setwd
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")

# Crested gibbon data preparation ----------

# Check for data leakage among training, valid and test datasets
# Function to extract the relevant identifier from the filename
extract_file_identifier <- function(filename) {
  components <- str_split_fixed(filename, "_", n = 6)
  identifier <- paste(components[, 3], components[, 4],components[, 5],sep = "_")
  return(identifier)
}

# Function to check for data leakage
check_data_leakage <- function(rootDir) {
  trainingDir <- file.path(rootDir, 'train')
  validationDir <- file.path(rootDir, 'valid')
  testDir <- file.path(rootDir, 'test')
  
  trainFiles <- list.files(trainingDir, pattern = "\\.jpg$", full.names = FALSE, recursive = TRUE)
  validationFiles <- list.files(validationDir, pattern = "\\.jpg$", full.names = FALSE, recursive = TRUE)
  testFiles <- list.files(testDir, pattern = "\\.jpg$", full.names = FALSE, recursive = TRUE)
  
  trainIds <- sapply(trainFiles, extract_file_identifier)
  validationIds <- sapply(validationFiles, extract_file_identifier)
  testIds <- sapply(testFiles, extract_file_identifier)
  
  trainValidationOverlap <- trainIds[which(trainIds %in% validationIds)]
  trainTestOverlap <- trainIds[which(trainIds %in% testIds)]
  validationTestOverlap <- testIds[which(testIds %in% validationIds)]
  
  if (length(trainValidationOverlap) == 0 & length(trainTestOverlap) == 0 & length(validationTestOverlap) == 0) {
    cat("No data leakage detected among the datasets.\n")
  } else {
    cat("Data leakage detected!\n")
    if (length(trainValidationOverlap) > 0) {
      cat("Overlap between training and validation datasets:\n", trainValidationOverlap, "\n")
    }
    if (length(trainTestOverlap) > 0) {
      cat("Overlap between training and test datasets:\n", trainTestOverlap, "\n")
    }
    if (length(validationTestOverlap) > 0) {
      cat("Overlap between validation and test datasets:\n", validationTestOverlap, "\n")
    }
  }
}

# Check for leakage in different datasets
check_data_leakage('data/training_images_sorted/Jahoo')

# Cambodia Binary Model Training ---------------------------------------------------------

# Location of spectrogram images for training
input.data.path <-  'data/training_images_sorted/Jahoo'

# Location of spectrogram images for testing
test.data.path <- 'data/training_images_sorted/Jahoo/test/'

# Training data folder short
trainingfolder.short <- 'imagescambodia'

# Whether to unfreeze.param the layers
unfreeze.param.param <- TRUE # FALSE means the features are frozen; TRUE unfrozen

# Number of epochs to include
epoch.iterations <- c(1,2,3,4,5,20)

# Train the models specifying different architectures
gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='alexnet',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")


gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='vgg16',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                             output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='vgg19',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='resnet18',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='resnet50',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                             output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='resnet152',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")


# Cambodia Binary Model Evaluation ----------------------------------------

performancetables.dir <- 'model_output/_imagescambodia_binary_unfrozen_TRUE_/performance_tables/'

PerformanceOutput <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir,
                                                      class='Gibbons',
                                                      model.type = "binary",
                                                      Thresh.val = 0)


PerformanceOutput$f1_plot


# Grey Gibbon Data Prep ---------------------------------------------------------
# Function to extract the relevant identifier from the filename
extract_file_identifier <- function(filename) {
  components <- str_split_fixed(filename, "_", n = 6)
  identifier <- paste(components[, 2], components[, 3],components[, 4],sep = "_")
  return(identifier)
}

# Function to check for data leakage
check_data_leakage <- function(rootDir) {
  trainingDir <- file.path(rootDir, 'train')
  validationDir <- file.path(rootDir, 'valid')
  testDir <- file.path(rootDir, 'test')
  
  
  trainFiles <- list.files(trainingDir, pattern = "\\.jpg$", full.names = FALSE, recursive = TRUE)
  validationFiles <- list.files(validationDir, pattern = "\\.jpg$", full.names = FALSE, recursive = TRUE)
  testFiles <- list.files(testDir, pattern = "\\.jpg$", full.names = FALSE, recursive = TRUE)
  
  trainIds <- sapply(trainFiles, extract_file_identifier)
  validationIds <- sapply(validationFiles, extract_file_identifier)
  testIds <- sapply(testFiles, extract_file_identifier)
  
  trainValidationOverlap <- trainIds[which(trainIds %in% validationIds)]
  trainTestOverlap <- trainIds[which(trainIds %in% testIds)]
  validationTestOverlap <- testIds[which(testIds %in% validationIds)]
  
  if (length(trainValidationOverlap) == 0 & length(trainTestOverlap) == 0 & length(validationTestOverlap) == 0) {
    cat("No data leakage detected among the datasets.\n")
  } else {
    cat("Data leakage detected!\n")
    if (length(trainValidationOverlap) > 0) {
      cat("Overlap between training and validation datasets:\n", trainValidationOverlap, "\n")
    }
    if (length(trainTestOverlap) > 0) {
      cat("Overlap between training and test datasets:\n", trainTestOverlap, "\n")
    }
    if (length(validationTestOverlap) > 0) {
      cat("Overlap between validation and test datasets:\n", validationTestOverlap, "\n")
    }
  }
}

# Check for leakage in different datasets
check_data_leakage('data/training_images_sorted/Danum/')


# Grey Gibbon Binary Model Training ---------------------------------------

# Location of spectrogram images for training
input.data.path <-  'data/training_images_sorted/Danum/'

# Location of spectrogram images for testing
test.data.path <- "data/training_images_sorted/Danum/test/"

# Training data folder short
trainingfolder.short <- 'imagesmalaysia'

# Whether to unfreeze.param the layers
unfreeze.param.param <- TRUE # FALSE means the features are frozen; TRUE unfrozen

# Number of epochs to include
epoch.iterations <- c(1,2,3,4,5,20)

# Train the models specifying different architectures
gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='alexnet',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")


gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='vgg16',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='vgg19',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='resnet18',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='resnet50',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='resnet152',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze.param = TRUE,
                             epoch.iterations=epoch.iterations,
                             early.stop = "yes",
                            output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

# Evaluate model performance
performancetables.dir <- "model_output/_imagesmalaysia_binary_unfrozen_TRUE_/performance_tables"

PerformanceOutput <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir,
                                                      class='Gibbons',
                                                      model.type = "binary")

PerformanceOutput$f1_plot
PerformanceOutput$best_f1$F1


# Multi Species Model Training --------------------------------------------
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

# Location of spectrogram images for training
input.data.path <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/data/training_images_sorted/Combined/'

# Location of spectrogram images for testing
test.data.path <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/data/training_images_sorted/Combined/test/'

# Training data folder short
trainingfolder.short <- 'imagesmulti'

# Whether to unfreeze.param the layers
unfreeze.param.param <- TRUE # FALSE means the features are frozen; TRUE unfrozen

# Number of epochs to include
epoch.iterations <- c(1,2,3,4,5,20)

# Allow early stopping?
early.stop <- 'yes'

# Train models using different architectures
gibbonNetR::train_CNN_multi(input.data.path=input.data.path,
                            architecture ='alexnet',
                            learning_rate = 0.001,
                            test.data=test.data.path,
                            unfreeze.param = TRUE,
                            epoch.iterations=epoch.iterations,
                            save.model= TRUE,
                            early.stop = "yes",
                           output.base.path = "model_output/",
                            trainingfolder=trainingfolder.short,
                            noise.category = "Noise")

gibbonNetR::train_CNN_multi(input.data.path=input.data.path,
                            architecture ='vgg16',
                            learning_rate = 0.001,
                            test.data=test.data.path,
                            unfreeze.param = TRUE,
                            epoch.iterations=epoch.iterations,
                            save.model= TRUE,
                            early.stop = "yes",
                           output.base.path = "model_output/",
                            trainingfolder=trainingfolder.short,
                            noise.category = "Noise")

gibbonNetR::train_CNN_multi(input.data.path=input.data.path,
                            architecture ='vgg19',
                            learning_rate = 0.001,
                            test.data=test.data.path,
                            unfreeze.param = TRUE,
                            epoch.iterations=epoch.iterations,
                            save.model= TRUE,
                            early.stop = "yes",
                           output.base.path = "model_output/",
                            trainingfolder=trainingfolder.short,
                            noise.category = "Noise")

gibbonNetR::train_CNN_multi(input.data.path=input.data.path,
                            architecture ='resnet18',
                            learning_rate = 0.001,
                            test.data=test.data.path,
                            unfreeze.param = TRUE,
                            epoch.iterations=epoch.iterations,
                            save.model= TRUE,
                            early.stop = "yes",
                           output.base.path = "model_output/",
                            trainingfolder=trainingfolder.short,
                            noise.category = "Noise")

gibbonNetR::train_CNN_multi(input.data.path=input.data.path,
                            architecture ='resnet50',
                            learning_rate = 0.001,
                            test.data=test.data.path,
                            unfreeze.param = TRUE,
                            epoch.iterations=epoch.iterations,
                            save.model= TRUE,
                            early.stop = "yes",
                           output.base.path = "model_output/",
                            trainingfolder=trainingfolder.short,
                            noise.category = "Noise")

gibbonNetR::train_CNN_multi(input.data.path=input.data.path,
                            architecture ='resnet152',
                            learning_rate = 0.001,
                            test.data=test.data.path,
                            unfreeze.param = TRUE,
                            epoch.iterations=epoch.iterations,
                            save.model= TRUE,
                            early.stop = "yes",
                           output.base.path = "model_output/",
                            trainingfolder=trainingfolder.short,
                            noise.category = "Noise")



# Evaluate performance of all models ----------------------------------

# Crested binary
performancetables.dir.crested <- 'model_output/_imagescambodia_binary_unfrozen_TRUE_/performance_tables/'
PerformanceOutputCrestedBinary <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir.crested,
                                                      class='Gibbons',
                                                      model.type = "binary", Thresh.val = 0)

as.data.frame(PerformanceOutputCrestedBinary$best_f1)
PerformanceOutputCrestedBinary$f1_plot
PerformanceOutputCrestedBinary$pr_plot


# Grey gibbons binary
performancetables.dir.grey <- 'model_output/_imagesmalaysia_binary_unfrozen_TRUE_/performance_tables/'
PerformanceOutputGreyBinary <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir.grey,
                                                                   class='Gibbons',
                                                                   model.type = "binary", Thresh.val = 0)

PerformanceOutputGreyBinary$f1_plot
PerformanceOutputGreyBinary$best_f1$F1


performancetables.dir.multi <- 'model_output/_imagesmulti_multi_unfrozen_TRUE_/performance_tables_multi/'

PerformanceOutputMultiCrested <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir.multi,
                                                           class='CrestedGibbons',
                                                           model.type = "multi",  Thresh.val = 0)

PerformanceOutputMultiCrested$f1_plot
PerformanceOutputMultiCrested$pr_plot
PerformanceOutputMultiCrested$best_f1$F1

PerformanceOutputMultiGrey <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir.multi,
                                                           class='GreyGibbons',
                                                           model.type = "multi", Thresh.val = 0)

PerformanceOutputMultiGrey$f1_plot
PerformanceOutputMultiGrey$pr_plot
PerformanceOutputMultiGrey$best_f1$F1


# Create table to report model performance --------------------------------

PerformanceOutputCrestedBinary$best_f1$Species <- 'Crested Gibbon'
PerformanceOutputGreyBinary$best_f1$Species <- 'Grey Gibbon'
PerformanceOutputMultiCrested$best_f1$Species <- 'Crested Gibbon'
PerformanceOutputMultiGrey$best_f1$Species  <- 'Grey Gibbon'

CombinedDF <- as.data.frame(rbind.data.frame(PerformanceOutputCrestedBinary$best_f1, PerformanceOutputGreyBinary$best_f1,
                 PerformanceOutputMultiCrested$best_f1, PerformanceOutputMultiGrey$best_f1))


CombinedDF <- CombinedDF[,c("Species", "Training Data","N epochs","CNN Architecture","Threshold","Precision","Recall","F1")]
CombinedDFSubset <-CombinedDF #subset(CombinedDF,Threshold >= 0.5)
CombinedDFSubset$Precision <- round(CombinedDFSubset$Precision,2)
CombinedDFSubset$Recall <- round(CombinedDFSubset$Recall,2)
CombinedDFSubset$F1 <- round(CombinedDFSubset$F1,2)

CombinedDFSubset$`Training Data` <- 
  ifelse(CombinedDFSubset$`Training Data` == 'imagescambodia' | CombinedDFSubset$`Training Data` == 'imagesmalaysia', 'Binary', 'MultiClass')

CombinedDFSubset$`Training Data` <- paste(CombinedDFSubset$Species, CombinedDFSubset$`Training Data`)
CombinedDFSubset <-CombinedDFSubset[,-c(1)]

head(CombinedDFSubset)
nrow(CombinedDFSubset)

# Assuming your data frame is named 'your_data'
# Replace 'your_data' with the actual name of your data frame

library(dplyr)

CombinedDFSubset$`N epochs` <- as.factor(CombinedDFSubset$`N epochs`)
CombinedDFSubset$Threshold <- as.factor(CombinedDFSubset$Threshold)

CombinedDFSubset$UniqueID <- as.factor(paste(CombinedDFSubset$`Training Data`,
                                   CombinedDFSubset$`CNN Architecture`,
                                   CombinedDFSubset$Precision,
                                   CombinedDFSubset$Recall,
                                   CombinedDFSubset$F1,sep='_'))

UniqueID_single <- unique(CombinedDFSubset$UniqueID)

ForFlextableCollapsed <- data.frame()

for(a in 1:length(UniqueID_single)){
  TempSubset <-  subset(CombinedDFSubset,UniqueID==UniqueID_single[a])
  UniqueEpoch <- droplevels(as.factor(dput(unique(TempSubset$`N epochs`))))
  UniqueThreshold <- droplevels(as.factor(dput(unique(TempSubset$Threshold))))
  TempRow <- TempSubset[1,]
  TempRow$`N epochs` <- paste(levels(UniqueEpoch),collapse = ", ")
  TempRow$Threshold <- paste(levels(UniqueThreshold),collapse = ", ")
  print(TempRow)
  ForFlextableCollapsed <- rbind.data.frame(ForFlextableCollapsed,
                                            TempRow)
}


ForFlextableCollapsed <- as.data.frame(ForFlextableCollapsed)
ForFlextableCollapsed <- ForFlextableCollapsed[,-c(8)]

CombinedDFSubsetFlextable <- flextable(ForFlextableCollapsed)
CombinedDFSubsetFlextable

CombinedDFSubsetFlextable <- merge_v(CombinedDFSubsetFlextable, j = c("Training Data"))
CombinedDFSubsetFlextable <- valign(CombinedDFSubsetFlextable,valign = "top")                        
CombinedDFSubsetFlextable

flextable::save_as_docx(CombinedDFSubsetFlextable,
                         path='Online Supporting Material Table 1. Performance on training split.docx')


