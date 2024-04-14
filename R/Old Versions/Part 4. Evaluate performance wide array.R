#NOTE that on April 8 DJC manually moved some misclassified images in the test dataset
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")

devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

# Top model for Crested Gibbons -------------------------------------------

trained_models_dir <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/top_models/cambodia_binary/'

image_data_dir <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/Images/'

evaluate_trainedmodel_performance(trained_models_dir=trained_models_dir,
                                  image_data_dir=image_data_dir,
                                  output_dir = "/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/model_eval/",
                                  positive.class='CrestedGibbons')


PerformanceOutPutTrained <- gibbonNetR::get_best_performance(performancetables.dir= "/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/model_eval/performance_tables_trained/",
                                                             model.type = 'binary',class='CrestedGibbons',Thresh.val =0.1)

PerformanceOutPutTrained$f1_plot
PerformanceOutPutTrained$best_f1$F1
PerformanceOutPutTrained$pr_plot
(PerformanceOutPutTrained$pr_plot)+scale_color_manual(values=matlab::jet.colors(6))


# Top model for Grey Gibbons -------------------------------------------

trained_models_dir <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/top_models/malaysia_binary/'

image_data_dir <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/Images/'

evaluate_trainedmodel_performance(trained_models_dir=trained_models_dir,
                                  image_data_dir=image_data_dir,
                                  output_dir = "/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/model_eval/",
                                  positive.class='GreyGibbons')


PerformanceOutPutTrained <- gibbonNetR::get_best_performance(performancetables.dir='/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/model_eval/performance_tables_trained/',
                                                             model.type = 'binary',class='Gibbons',Thresh.val =0.1)

PerformanceOutPutTrained$f1_plot
PerformanceOutPutTrained$best_f1$F1
PerformanceOutPutTrained$pr_plot
(PerformanceOutPutTrained$pr_plot)+scale_color_manual(values=matlab::jet.colors(6))

# Cambodia multi ----------------------------------------------------------

trained_models_dir <- "/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/_imagesmulti_multi_unfrozen_TRUE_/"


#image_data_dir <- '/Volumes/DJC 1TB/VocalIndividualityClips/RandomSelectionImages/'
image_data_dir <- "/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/Images/"

trainingfolder <- 'imagesmulti'

class_names <- c("CrestedGibbons", "GreyGibbons", "Noise")

evaluate_trainedmodel_performance_multi(trained_models_dir=trained_models_dir,
                                        class_names=class_names,
                                        #trainingfolder=trainingfolder,
                                        image_data_dir=image_data_dir,
                                        output_dir="/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/model_eval_multi/",
                                        noise.category = "Noise")



PerformanceOutPutTrained <- gibbonNetR::get_best_performance(performancetables.dir='/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/model_eval_multi/performance_tables_multi_trained',
                                                             model.type = 'multi',
                                                             class='CrestedGibbons',Thresh.val =0.1)

PerformanceOutPutTrained$f1_plot
PerformanceOutPutTrained$best_f1$F1
PerformanceOutPutTrained$pr_plot

(PerformanceOutPutTrained$pr_plot)+scale_color_manual(values=matlab::jet.colors(6))


trained_models_dir <- "/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/_imagesmulti_multi_unfrozen_TRUE_/"

#image_data_dir <- '/Volumes/DJC 1TB/VocalIndividualityClips/RandomSelectionImages/'
image_data_dir <- "/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/Images/"

trainingfolder <- 'imagesmulti'

class_names <- c("CrestedGibbons", "GreyGibbons", "Noise")

evaluate_trainedmodel_performance_multi(trained_models_dir=trained_models_dir,
                                        class_names=class_names,
                                        #trainingfolder=trainingfolder,
                                        image_data_dir=image_data_dir,
                                        output_dir="/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/model_eval_multi/",
                                        noise.category = "Noise")



PerformanceOutPutTrained <- gibbonNetR::get_best_performance(performancetables.dir='/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/model_eval_multi/performance_tables_multi_trained',
                                                             model.type = 'multi',
                                                             class='GreyGibbons',Thresh.val =0.1)

PerformanceOutPutTrained$f1_plot
PerformanceOutPutTrained$best_f1$F1
PerformanceOutPutTrained$pr_plot

# Evaluate performance on different site/species test data ----------------------------------
library(flextable)
library(dplyr)

# Crested binary
PerformanceOutputTestCrestedBinary <- gibbonNetR::get_best_performance(performancetables.dir='/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/model_eval_allmodels/performance_tables_trained/',
                                                                       model.type = 'binary',class='Gibbons',
                                                                       Thresh.val = 0.1)

PerformanceOutputTestCrestedBinary$f1_plot
PerformanceOutputTestCrestedBinary$best_f1$F1
PerformanceOutputTestCrestedBinary$best_precision

PerformanceOutputTestCrestedBinary$best_f1 <- PerformanceOutputTestCrestedBinary$best_f1[,-c(19)]

# Grey gibbons binary
PerformanceOutputTestGreyBinary <- gibbonNetR::get_best_performance(performancetables.dir='/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/model_eval_allmodels/performance_tables_trained',
                                                                    model.type = 'binary',class='Gibbons',Thresh.val = 0.1)

PerformanceOutputTestGreyBinary$f1_plot
PerformanceOutputTestGreyBinary$best_f1$F1
PerformanceOutputTestGreyBinary$best_f1  <- PerformanceOutputTestGreyBinary$best_f1[,-c(19)]


performancetables.dir.multi.crested <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/model_eval_multi/performance_tables_multi_trained/'

PerformanceOutputTestMultiCrested <-  gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir.multi.crested,
                                                                       class='CrestedGibbons',Thresh.val = 0.1)

PerformanceOutputTestMultiCrested$f1_plot
PerformanceOutputTestMultiCrested$best_f1$F1

performancetables.dir.multi.grey <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/model_eval_multi/performance_tables_multi_trained/'

PerformanceOutputTestMultiGrey <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir.multi.grey,
                                                                   class='GreyGibbons',Thresh.val = 0.1)

PerformanceOutputTestMultiGrey$f1_plot

PerformanceOutputTestMultiGrey$best_f1$F1

PerformanceOutputTestCrestedBinary$best_f1$Species <- 'Crested Gibbon'
PerformanceOutputTestGreyBinary$best_f1$Species <- 'Grey Gibbon'
PerformanceOutputTestMultiCrested$best_f1$Species <- 'Crested Gibbon'
PerformanceOutputTestMultiGrey$best_f1$Species  <- 'Grey Gibbon'

PerformanceOutputTestCrestedBinary$best_precision$Species <- 'Crested Gibbon'
PerformanceOutputTestGreyBinary$best_precision$Species <- 'Grey Gibbon'
PerformanceOutputTestMultiCrested$best_precision$Species <- 'Crested Gibbon'
PerformanceOutputTestMultiGrey$best_precision$Species  <- 'Grey Gibbon'

PerformanceOutputTestCrestedBinary$best_recall$Species <- 'Crested Gibbon'
PerformanceOutputTestGreyBinary$best_recall$Species <- 'Grey Gibbon'
PerformanceOutputTestMultiCrested$best_recall$Species <- 'Crested Gibbon'
PerformanceOutputTestMultiGrey$best_recall$Species  <- 'Grey Gibbon'

columns_sub <- c("Species", "Training Data", "N epochs", "CNN Architecture", "Threshold", "Precision", "Recall", "F1")

CombinedDFTest <- 
  rbind.data.frame(PerformanceOutputTestCrestedBinary$best_f1[, columns_sub],
                   PerformanceOutputTestGreyBinary$best_f1[, columns_sub],
                   PerformanceOutputTestMultiCrested$best_f1[, columns_sub],
                   PerformanceOutputTestMultiGrey$best_f1[, columns_sub],
                   PerformanceOutputTestCrestedBinary$best_recall[, columns_sub],
                   PerformanceOutputTestGreyBinary$best_recall[, columns_sub],
                   PerformanceOutputTestMultiCrested$best_recall[, columns_sub],
                   PerformanceOutputTestMultiGrey$best_recall[, columns_sub],
                   PerformanceOutputTestCrestedBinary$best_precision[, columns_sub],
                   PerformanceOutputTestGreyBinary$best_precision[, columns_sub],
                   PerformanceOutputTestMultiCrested$best_precision[, columns_sub],
                   PerformanceOutputTestMultiGrey$best_precision[, columns_sub]
  )

nrow(CombinedDFTest)
head(CombinedDFTest)

CombinedDFTest$Precision <- round(CombinedDFTest$Precision,2)
CombinedDFTest$Recall <- round(CombinedDFTest$Recall,2)
CombinedDFTest$F1 <- round(CombinedDFTest$F1,2)

CombinedDFTest$`Training Data` <- ifelse(CombinedDFTest$`Training Data`=='imagesmulti','Multi-class','binary')
CombinedDFTest$`Training Data` <- paste(CombinedDFTest$Species, CombinedDFTest$`Training Data`)
CombinedDFTest <-CombinedDFTest[,-c(1)]

CombinedDFTest$`CNN Architecture` <- 
  str_split_fixed(CombinedDFTest$`CNN Architecture`,pattern = '_',n=2)[,1]


CombinedDFTestFlextable <- flextable(CombinedDFTest[1:4,])
CombinedDFTestFlextable



# flextable::save_as_docx(CombinedDFTestFlextable,
#                         path='Table 2 Performance on test data.docx')


# -------------------------------------------------------------------------


# Create precision, recall, F1 curve for top models

BestF1data.frameCrestedGibbonBinary <- read.csv('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/model_eval_allmodels/performance_tables_trained/imagescambodia_5_resnet152_model_TransferLearningTrainedModel.csv')

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

BestF1data.frameGreyGibbonBinary <- read.csv('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/model_eval_allmodels/performance_tables_trained/imagesmalaysia_2_resnet152_model_TransferLearningTrainedModel.csv')

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


BestF1data.frameGreyGibbonMulti <- read.csv('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/model_eval_multi/performance_tables_multi_trained/imagesmulti_1_resnet50_model_TransferLearningTrainedModel.csv')

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



BestF1data.frameCrestedGibbonMulti <- read.csv('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/model_eval_multi/performance_tables_multi_trained/imagesmulti_5_resnet50_model_TransferLearningTrainedModel.csv')

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

# Combine plots -----------------------------------------------------------

cowplot::plot_grid(CrestedGibbonBinaryPlot,GreyGibbonBinaryPlot,
                   CrestedGibbonMultiPlot,GreyGibbonMultiPlot,
                   labels=c('A)','B)','C)', 'D)'), label_x = 0.9)
