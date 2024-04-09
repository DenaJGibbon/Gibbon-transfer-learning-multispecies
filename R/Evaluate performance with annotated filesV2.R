devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")

ModelPath <- 'model_output/_imagescambodia_binary_unfrozen_TRUE_/_imagescambodia_5_resnet50_model.pt'

SoundFileDir <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/SoundFiles/'

deploy_CNN_binary(
  clip_duration = 12,
  max_freq_khz = 3,
  architecture='resnet', # Change manually
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRoutputV2/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRoutputV2/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRoutputV2/Wavs/',
  detect_pattern=NA,# c('_050','_060'), 
  top_model_path = ModelPath,
  path_to_files = SoundFileDir,
  positive.class = 'Gibbons',
  negative.class = 'Noise',
  save_wav = FALSE,
  threshold = 0.1
)



# Binary example -------------------------------------------------------------------------

TopModelBinary <- 'model_output/_imagesmalaysia_binary_unfrozen_TRUE_/_imagesmalaysia_3_vgg19_model.pt'

DanumSoundFiles <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/SoundFiles'

deploy_CNN_binary(
  clip_duration = 12,
  max_freq_khz = 2,
  architecture='vgg19', # Change manually
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutputV2/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutputV2/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/gibbonNetRoutputV2/Wavs/',
  detect_pattern=NA,
  top_model_path = TopModelBinary,
  path_to_files = DanumSoundFiles,
  positive.class = 'Gibbons',
  negative.class = 'Noise',
  save_wav = TRUE,
  threshold = .1
)

# # Multi example -------------------------------------------------------------------------
# 
TopModelMulti <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/top_models/combined_multi/_imagesmulti_4_vgg16_model.pt'
# 
DanumSoundFiles <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley/SoundFiles/'
# 
deploy_CNN_multi(
  clip_duration = 12,
  architecture='vgg19',
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley//gibbonNetRMultiV2/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley//gibbonNetRMultiV2/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/DanumValley//gibbonNetRMultiV2/Wavs',
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

# 
TopModelMulti <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/top_models/combined_multi/_imagesmulti_3_resnet50_model.pt'
# 
JahooSoundFiles <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/SoundFiles/'
# 
deploy_CNN_multi(
  clip_duration = 12,
  architecture='resnet50',
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/gibbonNetRMultiV2/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo//gibbonNetRMultiV2/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo//gibbonNetRMultiV2/Wavs',
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


