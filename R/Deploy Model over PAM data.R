devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

ListofDirectory <- list.files("/Users/denaclink/Library/CloudStorage/Box-Box/Cambodia 2022/Wide array pilot",full.names = T)
class_names <- c("CrestedGibbons", "GreyGibbons", "Noise")
ModelPath <- 'model_output/top_models/combined_multi/_imagesmulti_20_vgg16_model.pt'

# Example
deploy_CNN_multi(
  clip_duration = 12,
  max_freq_khz = 3,
  architecture='vgg16', # Change manually
  output_folder = '/Volumes/Clink Data Backup/KSWSPilotArray/Images/',
  output_folder_selections = '/Volumes/Clink Data Backup/KSWSPilotArray/Selections/',
  output_folder_wav = '/Volumes/Clink Data Backup/KSWSPilotArray/Wavs/',
  detect_pattern= c( '_050','_060','_070','_080','_090','_100'),
  top_model_path = ModelPath,
  path_to_files = ListofDirectory[2],
  class_names = class_names,
  noise_category = 'Noise',
  single_class = TRUE,
  single_class_category = "CrestedGibbons",
  save_wav = TRUE,
  threshold = .5
)
