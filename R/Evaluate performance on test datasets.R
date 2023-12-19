
# Top model for Crested Gibbons -------------------------------------------

trained_models_dir <- 'model_output/top_models/cambodia_binary'

#image_data_dir <- '/Volumes/DJC 1TB/VocalIndividualityClips/RandomSelectionImages/'
image_data_dir <- 'data/testimages/imagesvietnam/test/'

evaluate_trainedmodel_performance(trained_models_dir=trained_models_dir,
                                  image_data_dir=image_data_dir,
                                  output_dir = "model_output/top_models/cambodia_binary/")


PerformanceOutPutTrained <- gibbonNetR::get_best_performance(performancetables.dir='model_output/top_models/cambodia_binary/performance_tables_trained/',
                                                             model.type = 'binary',class='Gibbons')

PerformanceOutPutTrained$f1_plot
PerformanceOutPutTrained$best_f1$F1
PerformanceOutPutTrained$pr_plot


# Top model for Grey Gibbons -------------------------------------------

trained_models_dir <- 'model_output/top_models/malaysia_binary/'

#image_data_dir <- '/Volumes/DJC 1TB/VocalIndividualityClips/RandomSelectionImages/'
image_data_dir <- '/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauImages/test/'

evaluate_trainedmodel_performance(trained_models_dir=trained_models_dir,
                                  image_data_dir=image_data_dir,
                                  output_dir = "model_output/top_models/malaysia_binary/")


PerformanceOutPutTrained <- gibbonNetR::get_best_performance(performancetables.dir='model_output/top_models/malaysia_binary/performance_tables_trained/',
                                                             model.type = 'binary',class='Gibbons')

PerformanceOutPutTrained$f1_plot
PerformanceOutPutTrained$best_f1$F1
PerformanceOutPutTrained$pr_plot

# Cambodia multi ----------------------------------------------------------

trained_models_dir <- "model_output/top_models/combined_multi/"

#image_data_dir <- '/Volumes/DJC 1TB/VocalIndividualityClips/RandomSelectionImages/'
image_data_dir <- "/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/TestData/MaliauVietnamCombined/test"

trainingfolder <- 'imagesmulti'

class_names <- c("CrestedGibbons", "GreyGibbons", "Noise")

evaluate_trainedmodel_performance_multi(trained_models_dir=trained_models_dir,
                                        class_names=class_names,
                                        trainingfolder=trainingfolder,
                                        image_data_dir=image_data_dir,
                                        output_dir="model_output/top_models/combined_multi/",
                                        noise.category = "Noise")




PerformanceOutPutTrained <- gibbonNetR::get_best_performance(performancetables.dir='model_output/top_models/combined_multi/performance_tables_multi_trained',
                                                             class='GreyGibbons')

PerformanceOutPutTrained$f1_plot
PerformanceOutPutTrained$best_f1$F1
PerformanceOutPutTrained$pr_plot

PerformanceOutPutTrained <- gibbonNetR::get_best_performance(performancetables.dir='model_output/top_models/combined_multi/performance_tables_multi_trained',
                                                             class='CrestedGibbons')

PerformanceOutPutTrained$f1_plot
PerformanceOutPutTrained$best_f1$F1
PerformanceOutPutTrained$pr_plot

