devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")
setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")

ListofDirectory <- list.files("/Users/denaclink/Library/CloudStorage/Box-Box/Cambodia 2022/Wide array pilot",full.names = T)

TopModelMulti <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/top_models/combined_multi/_imagesmulti_2_resnet50_model.pt'
# 
JahooSoundFiles <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/Jahoo/SoundFiles/'

for(c in rev(1:length(ListofDirectory))){
  print(ListofDirectory[c])
  
deploy_CNN_multi(
  clip_duration = 12,
  max_freq_khz = 3,
  architecture='resnet',
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Wavs/',
  detect_pattern= c('_050','_060'),
  top_model_path = TopModelMulti,
  path_to_files = ListofDirectory[c],
  class_names = c('CrestedGibbon','GreyGibbon','Noise'),
  noise_category = 'Noise',
  single_class = TRUE,
  single_class_category='CrestedGibbon',
  save_wav = TRUE,
  threshold = .9
)

}

TopModelMulti <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/model_output/top_models/combined_multi/_imagesmulti_5_resnet50_model.pt'

DanumSoundFiles <- '/Volumes/Dena Clink Toshiba 3 TB/SWIFT_sparse_array_Danum/'

ListofDirectory <- list.files(DanumSoundFiles,full.names = T)

ListofDirectory <- c("/Users/denaclink/Library/CloudStorage/Box-Box/CCB Datastore/Projects/2016/2016_UCDavis_Borneo_T0010/SWIFT_sparse_array_Danum/S14_000",
                     "/Users/denaclink/Library/CloudStorage/Box-Box/CCB Datastore/Projects/2016/2016_UCDavis_Borneo_T0010/SWIFT_sparse_array_Danum/S13_000",
                     "/Users/denaclink/Library/CloudStorage/Box-Box/CCB Datastore/Projects/2016/2016_UCDavis_Borneo_T0010/SWIFT_sparse_array_Danum/S12_000",
                     "/Users/denaclink/Library/CloudStorage/Box-Box/CCB Datastore/Projects/2016/2016_UCDavis_Borneo_T0010/SWIFT_sparse_array_Danum/S11_000")

for(c in (2:length(ListofDirectory))){
  print(ListofDirectory[c])
  
  deploy_CNN_multi(
    clip_duration = 12,
    max_freq_khz = 2,
    architecture='resnet',
    output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Images/',
    output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Selections/',
    output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Wavs/',
    detect_pattern= c('_060'),
    top_model_path = TopModelMulti,
    path_to_files = ListofDirectory[c],
    class_names = c('CrestedGibbon','GreyGibbon','Noise'),
    noise_category = 'Noise',
    single_class = TRUE,
    single_class_category='GreyGibbon',
    save_wav = TRUE,
    threshold = .5
  )
  
}



  # Binary example
  deploy_CNN_binary(
    clip_duration = 12,
    max_freq_khz = 3,
    architecture='resnet', # Change manually
    output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Images/',
    output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Selections/',
    output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Wavs/',
    detect_pattern= c('_050'),
    top_model_path = ModelPath,
    path_to_files = ListofDirectory[c],
    positive.class = 'Gibbons',
    negative.class = 'Noise',
    save_wav = TRUE,
    threshold = .8
  )
  gc()
}


#Stopped: c=5 [1] "43 out of 117" # Need to go to 74
# [1] "R1056_WA_20220907_050002.wav"


# Deploy binary model -----------------------------------------------------

TopModelBinary <- 'model_output/top_models/malaysia_binary/_imagesmalaysia_5_resnet18_model.pt'

ListofDirectoryBinary <- list.files('/Volumes/Dena Clink Toshiba 3 TB/SWIFT_sparse_array_Danum/',
                                    full.names = T)

# Binary example
deploy_CNN_binary(
  clip_duration = 12,
  max_freq_khz = 2,
  architecture='resnet', # Change manually
  output_folder = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Images/',
  output_folder_selections = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Selections/',
  output_folder_wav = '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Wavs/',
  detect_pattern=c('_060'),
  top_model_path = TopModelBinary,
  path_to_files = ListofDirectoryBinary[4],
  positive.class = 'Gibbons',
  negative.class = 'Noise',
  save_wav = TRUE,
  threshold = .5
)

# Focus on 0.9 threshold
TruePositive <- list.files("/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Images/TP",
           full.names = T)

TruePositiveShort <- list.files("/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Images/TP",
                                full.names = F)



Probs <- as.numeric(str_split_fixed(TruePositiveShort,pattern = '_', n=10)[,6])

ProbsIndex <- which(Probs >= 0.9)

output_folder_wav <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/ImagesOver90/TP/'

file.copy(TruePositive[ProbsIndex],
          to= paste(output_folder_wav,
                    TruePositiveShort[ProbsIndex], sep=''))


FalsePositive <- list.files("/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Images/FP",
                           full.names = T,pattern = '.jpg')

FalsePositiveShort <- list.files("/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Images/FP",
                                full.names = F,pattern = '.jpg')



Probs <- as.numeric(str_split_fixed(FalsePositiveShort,pattern = '_', n=10)[,6])

ProbsIndex <- which(Probs >= 0.9)

ouFPut_folder_wav <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/ImagesOver90/FP/'

file.copy(FalsePositive[ProbsIndex],
          to= paste(ouFPut_folder_wav,
                    FalsePositiveShort[ProbsIndex], sep=''))

AllPositive <- list.files("/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Images/",
                            full.names = T,pattern = '.jpg')

AllPositiveShort <- list.files("/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Images/",
                                 full.names = F,pattern = '.jpg')


Probs <- as.numeric(str_split_fixed(AllPositiveShort,pattern = '_', n=10)[,6])

ProbsIndex <- which(Probs >= 0.9)

ouut_folder_wav <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/ImagesOver90//'

file.copy(AllPositive[ProbsIndex],
          to= paste(ouut_folder_wav,
                    AllPositiveShort[ProbsIndex], sep=''))



