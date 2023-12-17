devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

class_names <- c("CrestedGibbons", "GreyGibbons", "Noise")
ModelPath <- 'model_output/top_models/combined_multi/_imagesmulti_20_vgg16_model.pt'

SoundFileDir <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/KSWSEvaluation/SoundFiles/'

deploy_CNN_multi(
  clip_duration = 12,
  max_freq_khz = 3,
  architecture='vgg16', # Change manually
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/KSWSEvaluation/gibbonNetRoutput/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/KSWSEvaluation/gibbonNetRoutput/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/KSWSEvaluation/gibbonNetRoutput/Wavs/',
  detect_pattern=NA,# c('_050','_060'), 
  top_model_path = ModelPath,
  path_to_files = SoundFileDir,
  class_names = class_names,
  noise_category = 'Noise',
  single_class = TRUE,
  single_class_category = "CrestedGibbons",
  save_wav = FALSE,
  threshold = .5
)




# Binary example -------------------------------------------------------------------------

TopModelBinary <- 'model_output/top_models/malaysia_binary/_imagesmalaysia_5_resnet18_model.pt'

DanumSoundFiles <- '/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/SoundFiles'

deploy_CNN_binary(
  clip_duration = 12,
  max_freq_khz = 2,
  architecture='resnet', # Change manually
  output_folder = '/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutput/Images/',
  output_folder_selections = '/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutput/Selections/',
  output_folder_wav = '/Volumes/Clink Data Backup/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutput/Wavs/',
  detect_pattern=NA,
  top_model_path = TopModelBinary,
  path_to_files = DanumSoundFiles,
  positive.class = 'Gibbons',
  negative.class = 'Noise',
  save_wav = TRUE,
  threshold = .5
)


