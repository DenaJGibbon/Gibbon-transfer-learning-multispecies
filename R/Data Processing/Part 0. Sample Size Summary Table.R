library(flextable)

# Summary of training, validation, and test splits

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


CombinedDanum <- cbind.data.frame(TrainDanumGibbonsN,TrainDanumNoiseN,ValidDanumGibbonsN,ValidDanumNoiseN,
                                  TestDanumGibbonsN,TestDanumNoiseN)

CombinedDanum


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


CombinedJahoo <- cbind.data.frame(TrainJahooGibbonsN,TrainJahooNoiseN,ValidJahooGibbonsN,ValidJahooNoiseN,
                                  TestJahooGibbonsN,TestJahooNoiseN)

colnames(CombinedJahoo) <- c('Training samples (Gibbon)',
                             'Training samples (Noise)',
                             'Validation samples (Gibbon)',
                             'Validation samples (Noise)',
                             'Test samples (Gibbon)',
                             'Test samples (Noise)')

colnames(CombinedDanum) <- c('Training samples (Gibbon)',
                             'Training samples (Noise)',
                             'Validation samples (Gibbon)',
                             'Validation samples (Noise)',
                             'Test samples (Gibbon)',
                             'Test samples (Noise)')


CombinedDanum$Species <- 'Grey Gibbon'
CombinedJahoo$Species <- 'Crested Gibbon'


CombinedDanum$Data<-  'Danum Valley Conservation Training Data'
CombinedJahoo$Data <-  'Jahoo Training Data'

CombinedSampleSize <- rbind.data.frame(CombinedDanum,CombinedJahoo)

CombinedSampleSize <- CombinedSampleSize[,c(8,7,1:6)]

CombinedSampleSizeFlex <- flextable::flextable(CombinedSampleSize)

CombinedSampleSizeFlex

flextable::save_as_docx(CombinedSampleSizeFlex,
                        path='Table XX Training data summary.docx')

