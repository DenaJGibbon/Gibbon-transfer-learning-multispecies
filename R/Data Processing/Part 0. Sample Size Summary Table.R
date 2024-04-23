library(flextable)

# Calculate sample sizes for training, validation, and test sets for Danum Valley Conservation Area
TrainDanumGibbons <- list.files('data/training_images_sorted/Danum/train/Gibbons/')
TrainDanumNoise <- list.files('data/training_images_sorted/Danum/train/Noise/')
TrainDanumGibbonsN <- length(TrainDanumGibbons)
TrainDanumNoiseN <- length(TrainDanumNoise)

ValidDanumGibbons <- list.files('data/training_images_sorted/Danum/valid/Gibbons/')
ValidDanumNoise <- list.files('data/training_images_sorted/Danum/valid/Noise/')
ValidDanumGibbonsN <- length(ValidDanumGibbons)
ValidDanumNoiseN <- length(ValidDanumNoise)

TestDanumGibbons <- list.files('data/training_images_sorted/Danum/test/Gibbons/')
TestDanumNoise <- list.files('data/training_images_sorted/Danum/test/Noise/')
TestDanumGibbonsN <- length(TestDanumGibbons)
TestDanumNoiseN <- length(TestDanumNoise)

# Combine sample sizes for Danum Valley Conservation Area into a data frame
CombinedDanum <- cbind.data.frame(TrainDanumGibbonsN, TrainDanumNoiseN, ValidDanumGibbonsN, ValidDanumNoiseN,
                                  TestDanumGibbonsN, TestDanumNoiseN)

# Calculate sample sizes for training, validation, and test sets for Keo Seima Wildlife Sanctuary
TrainJahooGibbons <- list.files('data/training_images_sorted/Jahoo/train/Gibbons/')
TrainJahooNoise <- list.files('data/training_images_sorted/Jahoo/train/Noise/')
TrainJahooGibbonsN <- length(TrainJahooGibbons)
TrainJahooNoiseN <- length(TrainJahooNoise)

ValidJahooGibbons <- list.files('data/training_images_sorted/Jahoo/valid/Gibbons/')
ValidJahooNoise <- list.files('data/training_images_sorted/Jahoo/valid/Noise/')
ValidJahooGibbonsN <- length(ValidJahooGibbons)
ValidJahooNoiseN <- length(ValidJahooNoise)

TestJahooGibbons <- list.files('data/training_images_sorted/Jahoo/test/Gibbons/')
TestJahooNoise <- list.files('data/training_images_sorted/Jahoo/test/Noise/')
TestJahooGibbonsN <- length(TestJahooGibbons)
TestJahooNoiseN <- length(TestJahooNoise)

# Combine sample sizes for Keo Seima Wildlife Sanctuary into a data frame
CombinedJahoo <- cbind.data.frame(TrainJahooGibbonsN, TrainJahooNoiseN, ValidJahooGibbonsN, ValidJahooNoiseN,
                                  TestJahooGibbonsN, TestJahooNoiseN)

# Rename columns for Danum Valley Conservation Area data
colnames(CombinedDanum) <- c('Training samples (Gibbon)', 'Training samples (Noise)',
                             'Validation samples (Gibbon)', 'Validation samples (Noise)',
                             'Test samples (Gibbon)', 'Test samples (Noise)')

# Rename columns for Keo Seima Wildlife Sanctuary data
colnames(CombinedJahoo) <- c('Training samples (Gibbon)', 'Training samples (Noise)',
                             'Validation samples (Gibbon)', 'Validation samples (Noise)',
                             'Test samples (Gibbon)', 'Test samples (Noise)')

# Add species information
CombinedDanum$Species <- 'Grey Gibbon'
CombinedJahoo$Species <- 'Crested Gibbon'

# Add dataset information
CombinedDanum$Data <- 'Danum Valley Conservation Training Data'
CombinedJahoo$Data <- 'Jahoo Training Data'

# Combine data frames for both conservation areas
CombinedSampleSize <- rbind.data.frame(CombinedDanum, CombinedJahoo)

# Reorder columns
CombinedSampleSize <- CombinedSampleSize[, c(8, 7, 1:6)]

# Create a flextable
CombinedSampleSizeFlex <- flextable::flextable(CombinedSampleSize)

# Display flextable
CombinedSampleSizeFlex

# Save flextable as a Word document
flextable::save_as_docx(CombinedSampleSizeFlex, path = 'Table XX Training data summary.docx')
