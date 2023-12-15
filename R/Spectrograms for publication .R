# Load dplyr package for data manipulation functions
library(dplyr)

# Location of spectrogram images for training
input.data.path <-  '/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies/data/imagesforpub/'

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
train_dl <- dataloader(train_ds, batch_size = 9, shuffle = F, drop_last = TRUE)

# Extract the next batch from the dataloader
batch <- train_dl$.iter()$.next()

# Extract the labels for the batch and determine class names
classes <- batch[[2]]
class_names <- list.files(input.data.path,recursive = T)
class_names <- str_split_fixed(class_names,pattern = '/',n=2)[,1]

# Convert the batch tensor of images to an array and process them:
# - The image tensor is permuted to change the dimension order.
# - The pixel values of the images are denormalized.
images <- as_array(batch[[1]]) %>% aperm(perm = c(1, 3, 4, 2))
mean <- c(0.485, 0.456, 0.406)
std <- c(0.229, 0.224, 0.225)
images <- std * images + mean
images <- images * 255
# Clip the pixel values to lie within [0, 255]
images[images > 255] <- 255
images[images < 0] <- 0

# Set the plotting parameters for a 4x6 grid
par(mfcol = c(3,3), mar = rep(1, 4))

# Visualize the images:
# - Use `purrr` functions to handle arrays.
# - Set the name of each image based on its class.
# - Convert each image to a raster format for plotting.
# - Finally, iterate over each image, plotting it and setting its title.
images %>%
  purrr::array_tree(1) %>%
  purrr::set_names(class_names) %>%
  purrr::map(as.raster, max = 255) %>%
  purrr::iwalk(~{plot(.x); title(.y)})
