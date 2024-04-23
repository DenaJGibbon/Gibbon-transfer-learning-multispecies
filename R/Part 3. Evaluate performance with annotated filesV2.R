# Load package and set working directory
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")

# Define paths and parameters for binary classification
ModelPath <- 'model_output/_imagescambodia_binary_unfrozen_TRUE_/_imagescambodia_5_resnet50_model.pt'
SoundFileDir <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/SoundFiles/'

# Deploy CNN for binary classification
deploy_CNN_binary(
  clip_duration = 12,
  max_freq_khz = 3,
  architecture='resnet', # Change manually
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRoutputFinal/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRoutputFinal/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRoutputFinal/Wavs/',
  detect_pattern=NA,# c('_050','_060'), 
  top_model_path = ModelPath,
  path_to_files = SoundFileDir,
  positive.class = 'Gibbons',
  negative.class = 'Noise',
  save_wav = FALSE,
  threshold = 0.1
)

# Define paths and parameters for another binary classification
TopModelBinary <- 'model_output/_imagesmalaysia_binary_unfrozen_TRUE_/_imagesmalaysia_3_vgg19_model.pt'
DanumSoundFiles <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/SoundFiles'

# Deploy CNN for binary classification
deploy_CNN_binary(
  clip_duration = 12,
  max_freq_khz = 2,
  architecture='vgg19', # Change manually
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutputFinal/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutputFinal/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutputFinal/Wavs/',
  detect_pattern=NA,
  top_model_path = TopModelBinary,
  path_to_files = DanumSoundFiles,
  positive.class = 'Gibbons',
  negative.class = 'Noise',
  save_wav = TRUE,
  threshold = .1
)

# Define paths and parameters for multi-class classification
TopModelMulti <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/top_models/combined_multi/_imagesmulti_3_resnet50_model.pt'
DanumSoundFiles <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/SoundFiles/'

# Deploy CNN for multi-class classification
deploy_CNN_multi(
  clip_duration = 12,
  architecture='resnet50',
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley//gibbonNetRMultiFinal/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley//gibbonNetRMultiFinal/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley//gibbonNetRMultiFinal/Wavs',
  #detect_pattern= 'NA',
  top_model_path = TopModelMulti,
  path_to_files = DanumSoundFiles,
  class_names = c('CrestedGibbon','GreyGibbon','Noise'),
  noise_category = 'Noise',
  single_class = TRUE,
  single_class_category='GreyGibbon',
  save_wav = FALSE,
  threshold = .1
)

# Define paths and parameters for another multi-class classification
TopModelMulti <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/top_models/combined_multi/_imagesmulti_3_resnet50_model.pt'
JahooSoundFiles <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/SoundFiles/'

# Deploy CNN for multi-class classification
deploy_CNN_multi(
  clip_duration = 12,
  max_freq_khz = 3,
  architecture='resnet50',
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRMultiFinal/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo//gibbonNetRMultiFinal/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo//gibbonNetRMultiFinal/Wavs',
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
