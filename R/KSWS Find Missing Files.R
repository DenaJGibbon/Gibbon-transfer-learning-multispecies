library(stringr)
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")
class_names <- c("CrestedGibbons", "GreyGibbons", "Noise")
ModelPath <- 'model_output/top_models/combined_multi/_imagesmulti_20_vgg16_model.pt'

# Create list of missing sound files
ListOfDirectories <- list.files('/Users/denaclink/Library/CloudStorage/Box-Box/Cambodia 2022/Wide array pilot',
                                full.names = T)

ListofImages <- list.files('/Volumes/Clink Data Backup/KSWSPilotArray/Images')

BaseNameImage <- str_split_fixed(ListofImages,pattern = '_', n=2)[,2]
BaseNameImage <- str_split_fixed(BaseNameImage,pattern = '.wav', n=2)[,1]
BaseNameImageUnique <- unique(BaseNameImage)



Seq <- c(2:5,7:9)

for(a in (Seq)) {
  WavFileList <- list.files(ListOfDirectories[a],full.names = T, recursive = T)
  WavFileList1 <- WavFileList[str_detect(WavFileList,c('_050'))]
  WavFileList2 <- WavFileList[str_detect(WavFileList,c('_060'))]
  ShortList <- c(WavFileList1,WavFileList2)
  ShortListCount <- str_count(ShortList[1],pattern ='/' ) +1
  ShortListSplit <- str_split_fixed(ShortList, pattern ='/' ,n=ShortListCount)[,ShortListCount]
  ShortListSplit <- str_split_fixed(ShortListSplit, pattern ='.wav' ,n=2)[,1]
  ListofWavs <- ShortList[-c(ShortListSplit %in% BaseNameImageUnique)]
  print(length(ListofWavs))
  print(a)
}

  # Multi-class example
  deploy_CNN_multi(
    clip_duration = 12,
    max_freq_khz = 3,
    architecture='vgg16', # Change manually
    output_folder = '/Volumes/Clink Data Backup/Images/',
    output_folder_selections = '/Volumes/Clink Data Backup/KSWSPilotArray/Selections/',
    output_folder_wav = '/Volumes/Clink Data Backup/KSWSPilotArray/Wavs/',
    detect_pattern='none', 
    top_model_path = ModelPath,
    path_to_files = list(ListofWavs),
    class_names = class_names,
    noise_category = 'Noise',
    single_class = TRUE,
    single_class_category = "CrestedGibbons",
    save_wav = TRUE,
    threshold = .5
  )
  
  
}





clip_duration = 12
max_freq_khz = 3
architecture='vgg16' # Change manually
output_folder = '/Volumes/Clink Data Backup/Images/'
output_folder_selections = '/Volumes/Clink Data Backup/KSWSPilotArray/Selections/'
output_folder_wav = '/Volumes/Clink Data Backup/KSWSPilotArray/Wavs/'
detect_pattern='none' 
top_model_path = ModelPath
path_to_files = list(ListofWavs)
class_names = class_names
noise_category = 'Noise'
single_class = TRUE
single_class_category = "CrestedGibbons"
save_wav = TRUE
threshold = .5



