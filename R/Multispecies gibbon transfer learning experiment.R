setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

# Prepare training data images --------------------------------------------
# Transfer learning multi-species gibbons
# gibbonNetR::spectrogram_images(
#   trainingBasePath = '/Volumes/DJC Files/MultiGibbonSpecies/JahooClips',
#   outputBasePath   = 'data/trainingimages/imagescambodia/',
#   minfreq.khz= 0.4, maxfreq.khz=3,
#   splits           = c(.6, .2, .2)  # 0% training, 0% validation, 100% testing
# )
# 
# 
# gibbonNetR::spectrogram_images(
#   trainingBasePath = '/Volumes/DJC Files/MultiGibbonSpecies/DanumLocArray',
#   outputBasePath   = 'data/trainingimages/imagesmalaysia/',
#   minfreq.khz= 0.4, maxfreq.khz=2,
#   splits           = c(.6, .2, .2)  # 0% training, 0% validation, 100% testing
# )
# 
# 
# gibbonNetR::spectrogram_images(
#   trainingBasePath = '/Volumes/DJC Files/MultiGibbonSpecies/MultiSpecies',
#   outputBasePath   = 'data/trainingimages/imagesmulti/',
#   minfreq.khz= 0.4, maxfreq.khz=2.5,
#   splits           = c(.6, .2, .2)  # 0% training, 0% validation, 100% testing
# )
#

# gibbonNetR::spectrogram_images(
#   trainingBasePath = '/Volumes/Clink Data Backup/DanumLocArray/BLEDDETECTOR/WavFiles/',
#   outputBasePath   = 'data/trainingimages/imagesmalaysia_locarray/',
#   minfreq.khz= 0.4, maxfreq.khz=2.5,
#   splits= c(.8, .2, 0)  # 0% training, 0% validation, 100% testing
# )
# Note had to manually move some misclassified noise images

# # Prepare test data images ------------------------------------------------
# 
# gibbonNetR::spectrogram_images(
#   trainingBasePath = '/Volumes/DJC Files/MultiGibbonSpecies/TestClipsVietnam/',
#   outputBasePath   = 'data/testimages/imagesvietnam/',
#   minfreq.khz= 0.4, maxfreq.khz=3,
#   splits           = c(0, 0, 1)  # 0% training, 0% validation, 100% testing
# )
# 
# 
# gibbonNetR::spectrogram_images(
#   trainingBasePath = '/Volumes/DJC Files/MultiGibbonSpecies/TestClipsMaliauBinary/',
#   outputBasePath   = 'data/testimages/imagesmaliau/',
#   minfreq.khz= 0.4, maxfreq.khz=2,
#   splits           = c(0, 0, 1)  # 0% training, 0% validation, 100% testing
# )
# # Note had to manually move a few misclassified images


# Cambodia Binary ---------------------------------------------------------

# Location of spectrogram images for training
input.data.path <-  'data/trainingimages/imagescambodia/'

# Location of spectrogram images for testing
test.data.path <- 'data/trainingimages/imagescambodia/test/'

# Training data folder short
trainingfolder.short <- 'imagescambodia'

# Whether to unfreeze the layers
unfreeze.param <- TRUE # FALSE means the features are frozen; TRUE unfrozen

# Number of epochs to include
epoch.iterations <- c(1,2,3,4,5,20)


gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='alexnet',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
                             epoch.iterations=epoch.iterations,
                            early.stop = "yes",
                             output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

performancetables.dir <- 'model_output/_imagescambodia_binary_unfrozen_TRUE_/performance_tables/'
PerformanceOutput <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir,
                                                      class='Gibbons',
                                                      model.type = "binary")

PerformanceOutput$f1_plot
PerformanceOutput$best_f1$F1


# Malaysia Binary ---------------------------------------------------------

# Location of spectrogram images for training
input.data.path <-  'data/trainingimages/imagesmalaysia/'

# Location of spectrogram images for testing
test.data.path <- "data/trainingimages/imagesmalaysia/test/"

# Training data folder short
trainingfolder.short <- 'imagesmalaysia'

# Whether to unfreeze the layers
unfreeze.param <- TRUE # FALSE means the features are frozen; TRUE unfrozen

# Number of epochs to include
epoch.iterations <- c(1,2,3,4,5,20)


gibbonNetR::train_CNN_binary(input.data.path=input.data.path,
                             architecture ='alexnet',
                             save.model= TRUE,
                             learning_rate = 0.001,
                             test.data=test.data.path,
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
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
                             unfreeze = TRUE,
                             epoch.iterations=epoch.iterations,
                            early.stop = "yes",
                             output.base.path = "model_output/",
                             trainingfolder=trainingfolder.short,
                             positive.class="Gibbons",
                             negative.class="Noise")

performancetables.dir <- "model_output/_imagesmalaysia_binary_unfrozen_TRUE_/performance_tables"

PerformanceOutput <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir,
                                                      class='Gibbons',
                                                      model.type = "binary")

PerformanceOutput$f1_plot
PerformanceOutput$best_f1$F1


# Multi species classification --------------------------------------------
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

# Location of spectrogram images for training
input.data.path <- 'data/trainingimages/imagesmulti/'

# Location of spectrogram images for testing
test.data.path <- 'data/trainingimages/imagesmulti/test/'

# Training data folder short
trainingfolder.short <- 'imagesmulti'

# Whether to unfreeze the layers
unfreeze.param <- TRUE # FALSE means the features are frozen; TRUE unfrozen

# Number of epochs to include
epoch.iterations <- c(1,2,3,4,5,20)

# Allow early stopping?
early.stop <- 'yes'

gibbonNetR::train_CNN_multi(input.data.path=input.data.path,
                            architecture ='alexnet',
                            learning_rate = 0.001,
                            test.data=test.data.path,
                            unfreeze = TRUE,
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
                            unfreeze = TRUE,
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
                            unfreeze = TRUE,
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
                            unfreeze = TRUE,
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
                            unfreeze = TRUE,
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
                            unfreeze = TRUE,
                            epoch.iterations=epoch.iterations,
                            save.model= TRUE,
                           early.stop = "yes",
                            output.base.path = "model_output/",
                            trainingfolder=trainingfolder.short,
                            noise.category = "Noise")


performancetables.dir.multi <- 'model_output/_imagesmulti_multi_unfrozen_TRUE_/performance_tables_multi/'

PerformanceOutputMulti <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir.multi,
                                                           class='CrestedGibbons',
                                                           model.type = "multi")

PerformanceOutputMulti$f1_plot
PerformanceOutputMulti$best_f1$F1

PerformanceOutputMulti <- gibbonNetR::get_best_performance(performancetables.dir=performancetables.dir.multi,
                                                           class='GreyGibbons',
                                                           model.type = "multi")

PerformanceOutputMulti$f1_plot

PerformanceOutputMulti$best_f1$F1


# Top F1 for each species
# Crested gibbons: multi: 0.926; binary: 0.977 AlexNet and ResNet50

# GreyGibbons: multi: 985 resnet50; binary: 0.965 VGG16 0.4



