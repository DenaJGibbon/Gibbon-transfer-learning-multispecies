
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Gibbon-transfer-learning-multispecies

<!-- badges: start -->
<!-- badges: end -->

This is the GitHub repository for the paper:

Clink DJ, Kim J, Cross-Jaya H, Ahmad AH, Hong M, Sala R, Birot H, Agger
C, Vu TT, Thi HNT, Chi TN, and H. Klinck. (under review). Automated
detection of gibbon calls from passive acoustic monitoring data using
convolutional neural networks in the ‘torch for R’ ecosystem.

This repo relies on the ‘gibbonNetR’ package that can be installed from
GitHub using the following code.

``` r
# If you don't have devtools installed
install.packages("devtools")

# Install gibbonNetR
devtools::install_github("https://github.com/DenaJGibbon/gibbonNetR")
```

For a tutorial see: <https://github.com/DenaJGibbon/gibbonNetR>.

## Description of ‘data’ folders

1.  **Folder Name: calldensityplots**
    - **Description:** Folder containing GPS data and image selections
      to create call density plots.
2.  **Folder Name: GPSData**
    - **Description:** Folder containing GPS data files.
    - **Content:** GPS files providing location data for all recording
      units. Also contains a script to process and create a .csv file
      with the points.
3.  **Folder Name: imagesforpub**
    - **Description:** Folder containing spectrogram images intended for
      publication.
4.  **Folder Name: ImagesforpubSoundFiles**
    - **Description:** Folder containing sound files corresponding to
      images intended for publication.
5.  **Folder Name: testimages**
    - **Description:** Folder containing test images for model
      evaluation.Test data come from Maliau Basin or Dakrong Nature
      Preserve.
6.  **Folder Name: training_images_sorted**
    - **Description:** Folder containing sorted training images.Images
      were sorted so that training. validation, and test contain clips
      from different recordings

## Description of R scripts

1.  **Script Name: Part 1. Train CNNs on gibbon data.R**
    - **Description:** Script for training Convolutional Neural Networks
      (CNNs) on gibbon data.
2.  **Script Name: Part 2. Evaluate performance on test datasets.R**
    - **Description:** Script for evaluating model performance on test
      datasets.
3.  **Script Name: Part 3. Evaluate performance with annotated
    filesV2.R**
    - **Description:** Script for evaluating model performance with
      annotated files (version 2).
4.  **Script Name: Part 4. Selection Table Model Performance Evaluation
    .R**
    - **Description:** Script for evaluating model performance on the
      wide array data using selection tables output by ‘gibbonNetR’.
5.  **Script Name: Part 5. Deploy Model over PAM data.R**
    - **Description:** Script for deploying model over passive acoustic
      monitoring (PAM) data. NOTE: Due to the size constraints we cannot
      make these data publicly available.
6.  **Script Name: Part 6. Call Density Plots.R**
    - **Description:** Script for generating call density plots.
7.  **Script Name: Part 7. Spectrograms for publication .R**
    - **Description:** Script for generating spectrograms for
      publication.
