# Load the dplyr package for data manipulation functions
library(dplyr)
library(gibbonNetR)

#devtools::load_all("/Users/denaclink/Desktop/RStudioProjects/gibbonNetR")

# Set the base path for the training data
trainingBasePath <- 'data/ImagesforpubSoundFiles/'

# List all folders within the training base path
TrainingFolders <- list.files(trainingBasePath, full.names = TRUE)

# List only the names of folders within the training base path
TrainingFoldersShort <- list.files(trainingBasePath, full.names = FALSE)

# Set the output directory path
outputdir <- 'data/imagesforpub'

# Create subset directories within the output directory
subset_directory <- paste(outputdir,TrainingFoldersShort, sep='/')

# Set new sample rate and minimum frequency
new.sampleratehz <- 16000
minfreq.khz <- 0.5

# Loop through each subset directory
for(a in 1:length(subset_directory)){
  
  # Assign the current subset directory path
  subset_directory_temp <- subset_directory[a]
  
  # Check if the directory exists, if not, create it
  if (!dir.exists(subset_directory_temp)) {
    dir.create(subset_directory_temp, recursive = TRUE)
    message('Created output dir: ', subset_directory_temp)
  } else {
    message(subset_directory_temp, ' already exists')
  }
  
  # List all files within the current training folder
  TempWavs <- list.files(TrainingFolders[a],full.names = T)
  
  # Loop through each file in the current training folder
  for(b in 1:length(TempWavs)){
    
    # Remove file extension to get the base filename
    wav_rm <- tools::file_path_sans_ext(basename(TempWavs[b]))
    # Define the filename for the JPEG file
    jpeg_filename <- file.path(subset_directory_temp, paste0(wav_rm, '.jpg'))
    
    # Convert the WAV file to a spectrogram image and save it as a JPEG
    jpeg(jpeg_filename, res = 150)
    
    # Read the WAV file
    short_wav <- tuneR::readWave(TempWavs[b])
    
    # Downsample the WAV file if new sample rate is specified
    if(new.sampleratehz != 'NA'){
      short_wav <- tuneR::downsample(short_wav,new.sampleratehz)
    }
    
    # Set maximum frequency based on conditions
    maxfreq.khz <- ifelse(a ==1 | a==2, 3,2)
    
    # Generate and plot the spectrogram
    seewave::spectro(short_wav, scale = FALSE, flim = c(minfreq.khz, maxfreq.khz), grid = FALSE)
    
    # Close the graphics device after plotting
    graphics.off()
  }
}

# Location of spectrogram images for training
input.data.path <-  'data/imagesforpub/'

# List all files in the input data path
basename(list.files(input.data.path,recursive = T))

# Create a dataset of images for training
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

# Create a dataloader from the dataset
train_dl <- dataloader(train_ds, batch_size = train_ds$.length(), shuffle = F, drop_last = TRUE)

# Extract the next batch from the dataloader
batch <- train_dl$.iter()$.next()

# Extract the labels for the batch and determine class names
classes <- batch[[2]]
class_names <- list.files(input.data.path,recursive = T)
Probs <- str_split_fixed(class_names,pattern = '.wav',n=2)[,2]
Probs <- str_split_fixed(Probs,pattern = '_',n=5)[,3]

class_names <- str_split_fixed(class_names,pattern = '/',n=2)[,1]

# Convert the batch tensor of images to an array and process them
images <- as_array(batch[[1]]) %>% aperm(perm = c(1, 3, 4, 2))

# Set the plotting parameters for a 4x6 grid
par(mfcol = c(3,4), mar = rep(1, 4))

# Define a function to normalize pixel values
normalize_pixel_values <- function(image) {
  normalized_image <- (image - min(image)) / (max(image) - min(image))
  return(normalized_image)
}

# Visualize the images
images %>%
  purrr::array_tree(1) %>%
  purrr::set_names(class_names) %>%
  purrr::map(~ as.raster(normalize_pixel_values(.x))) %>%
  purrr::iwalk(~{plot(.x); title(.y)}) 
