devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")
ListofDirectory <- list.files("/Users/denaclink/Library/CloudStorage/Box-Box/Cambodia 2022/Wide array pilot",full.names = T)
class_names <- c("CrestedGibbons", "GreyGibbons", "Noise")
ModelPath <- 'model_output/top_models/combined_multi/_imagesmulti_20_vgg16_model.pt'

for(c in rev(1:length(ListofDirectory))){
   print(ListofDirectory[c])
# Multi-class example
deploy_CNN_multi1(
  clip_duration = 12,
  max_freq_khz = 3,
  architecture='vgg16', # Change manually
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutput/KSWS/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutput/KSWS/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutput/KSWS/Wavs/',
  detect_pattern= c('_050','_060'), 
  top_model_path = ModelPath,
  path_to_files = ListofDirectory[c],
  class_names = class_names,
  noise_category = 'Noise',
  single_class = TRUE,
  single_class_category = "CrestedGibbons",
  save_wav = TRUE,
  threshold = .5
)
}



# Deploy binary model -----------------------------------------------------

TopModelBinary <- 'model_output/top_models/malaysia_binary/_imagesmalaysia_5_resnet18_model.pt'

ListofDirectoryBinary <- list.files('/Volumes/Dena Clink Toshiba 3 TB/SWIFT_sparse_array_Danum/',
                                    full.names = T)

# Binary example
deploy_CNN_binary(
  clip_duration = 12,
  max_freq_khz = 2,
  architecture='resnet', # Change manually
  output_folder = '/Volumes/Dena Clink Toshiba 3 TB/gibbonNetRDanum/Images/',
  output_folder_selections = '/Volumes/Dena Clink Toshiba 3 TB/gibbonNetRDanum/Selections/',
  output_folder_wav = '/Volumes/Dena Clink Toshiba 3 TB/gibbonNetRDanum/Wavs/',
  detect_pattern=c('_060'),
  top_model_path = TopModelBinary,
  path_to_files = ListofDirectoryBinary[4],
  positive.class = 'Gibbons',
  negative.class = 'Noise',
  save_wav = TRUE,
  threshold = .5
)


