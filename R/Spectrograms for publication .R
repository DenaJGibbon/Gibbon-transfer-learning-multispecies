# Load dplyr package for data manipulation functions
library(dplyr)
devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

trainingBasePath <- '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/data/ImagesforpubSoundFiles/'

TrainingFolders <- list.files(trainingBasePath, full.names = TRUE)

TrainingFoldersShort <- list.files(trainingBasePath, full.names = FALSE)

outputdir <- 'data/imagesforpub'

subset_directory <- paste(outputdir,TrainingFoldersShort, sep='/')

new.sampleratehz <- 16000
minfreq.khz <- 0.5

for(a in 1:length(subset_directory)){
  
  subset_directory_temp <- subset_directory[a]
  
  if (!dir.exists(subset_directory_temp)) {
    dir.create(subset_directory_temp, recursive = TRUE)
    message('Created output dir: ', subset_directory_temp)
  } else {
    message(subset_directory_temp, ' already exists')
  }
  
  TempWavs <- list.files(TrainingFolders[a],full.names = T)
  
  for(b in 1:length(TempWavs)){
    
    wav_rm <- tools::file_path_sans_ext(basename(TempWavs[b]))
    jpeg_filename <- file.path(subset_directory_temp, paste0(wav_rm, '.jpg'))
    
    jpeg(jpeg_filename, res = 150)
    
    short_wav <- tuneR::readWave(TempWavs[b])
    
    if(new.sampleratehz != 'NA'){
      short_wav <- tuneR::downsample(short_wav,new.sampleratehz)
    }
    
    maxfreq.khz <- ifelse(a ==1 | a==2, 3,2)
    
    seewave::spectro(short_wav, scale = FALSE, flim = c(minfreq.khz, maxfreq.khz), grid = FALSE 
                     #main=basename(subset_directory_temp)
                     )
    
    graphics.off()
  }
}



# Location of spectrogram images for training
input.data.path <-  '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/data/imagesforpub/'
#input.data.path <- '/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutput/PublicationTruePositives/'

basename(list.files(input.data.path,recursive = T))

# Create a dataset of images:
# - The images are sourced from the 'train' subdirectory within the specified path `input.data.path`.
# - The images undergo several transformations:
#     1. They are converted to tensors.
#     2. They are resized to 224x224 pixels.
#     3. Their pixel values are normalized.
train_ds <- image_folder_dataset(
  file.path(input.data.path),   # Path to the image directory
  transform = . %>%
    torchvision::transform_to_tensor() %>%
    torchvision::transform_resize(size = c(224, 224)) %>%
    torchvision::transform_normalize(
      mean = c(0.485, 0.456, 0.406),      # Mean for normalization
      std = c(0.229, 0.224, 0.225)        # Standard deviation for normalization
    ),
  target_transform = function(x) as.double(x) - 1  # Transformation for target/labels
)

# Create a dataloader from the dataset:
# - This helps in efficiently loading and batching the data.
# - The batch size is set to 24, with shuffling enabled and the last incomplete batch is dropped.
train_dl <- dataloader(train_ds, batch_size = train_ds$.length(), shuffle = F, drop_last = TRUE)

# Extract the next batch from the dataloader
batch <- train_dl$.iter()$.next()

# Extract the labels for the batch and determine class names
classes <- batch[[2]]
class_names <- list.files(input.data.path,recursive = T)
Probs <- str_split_fixed(class_names,pattern = '.wav',n=2)[,2]
Probs <- str_split_fixed(Probs,pattern = '_',n=5)[,3]

class_names <- str_split_fixed(class_names,pattern = '/',n=2)[,1]
#class_names <- paste(class_names,Probs)
# Convert the batch tensor of images to an array and process them:
# - The image tensor is permuted to change the dimension order.
# - The pixel values of the images are denormalized.
images <- as_array(batch[[1]]) %>% aperm(perm = c(1, 3, 4, 2))


# Set the plotting parameters for a 4x6 grid


# Visualize the images:
# - Use `purrr` functions to handle arrays.
# - Set the name of each image based on its class.
# - Convert each image to a raster format for plotting.
# - Finally, iterate over each image, plotting it and setting its title.
# pdf('SpectrogramImages.pdf')
par(mfcol = c(3,4), mar = rep(1, 4))

#Define a function to normalize pixel values
normalize_pixel_values <- function(image) {
  normalized_image <- (image - min(image)) / (max(image) - min(image))
  return(normalized_image)
}


images %>%
  purrr::array_tree(1) %>%
  purrr::set_names(class_names) %>%
  purrr::map(~ as.raster(normalize_pixel_values(.x))) %>%
  purrr::iwalk(~{plot(.x); title(.y)}) 
#graphics.off()
