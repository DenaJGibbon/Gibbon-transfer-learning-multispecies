# Load necessary libraries
library(ggplot2)
library(sp)
library(gstat)
library(stringr)

setwd("/Users/denaclink/Desktop/RStudioProjects/Gibbon-transfer-learning-multispecies")

# Danum Valley ------------------------------------------------------------

TempImagesDanum <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/ImagesOver90/TP/')
TempImagesDanum <- str_split_fixed(TempImagesDanum,pattern = '_',n=4)
recorder <- TempImagesDanum[,2]
date <- TempImagesDanum[,3]
DanumTimingDF <- cbind.data.frame(recorder,date)

TempDanumFiles <-list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/Selections/')
TempDanumFiles <-str_split_fixed(TempDanumFiles,pattern = '-__',n=2)[,2]
TempDanumFiles <-str_split_fixed(TempDanumFiles,pattern = '_',n=2)[,1]

DanumTable <- as.data.frame(table(TempDanumFiles))
colnames(DanumTable) <- c('Recorder','Freq')
DanumTable$Freq <- DanumTable$Freq*2 # Convert to hours

# Read in GPS data
danum.gps.pts <- read.csv("data/calldensityplots/DanumValleyGPS.csv")

#DanumTimingDF$recorder <- droplevels(as.factor(DanumTimingDF$recorder))
recorder.index <- unique(DanumTimingDF$recorder)

interpolation.df <- data.frame()
for (x in 1:length(recorder.index)) {
  index.sub <- recorder.index[x]
  gps.sub <- subset(danum.gps.pts, Name == as.character(index.sub))
  detects.sub <- subset(DanumTimingDF, recorder == as.character(index.sub))
  detects.sub <- detects.sub[-which(duplicated(detects.sub)),]
  new.df <- cbind.data.frame(gps.sub$Name, gps.sub$latitude, 
                             gps.sub$longitude, nrow(detects.sub))
  colnames(new.df) <- c("name", "y", "x", "n.detect")
  
  TempRecRow <- subset(DanumTable,Recorder==index.sub)
  new.df$n.detect <- new.df$n.detect/TempRecRow$Freq
  
  interpolation.df <- rbind.data.frame(interpolation.df, 
                                       new.df)
}

interpolation.df.for.pts <- interpolation.df
x.range <- as.numeric(c(min(interpolation.df$x), max(interpolation.df$x)))
y.range <- as.numeric(c(min(interpolation.df$y), max(interpolation.df$y)))
sp::coordinates(interpolation.df) = ~x + y
grd <- expand.grid(x = seq(from = x.range[1], to = x.range[2], 
                           by = 1e-05), y = seq(from = y.range[1], to = y.range[2], 
                                                by = 1e-05))
sp::coordinates(grd) <- ~x + y
sp::gridded(grd) <- TRUE
idw <- gstat::idw(formula = n.detect ~ 1, locations = interpolation.df, 
                  newdata = grd)
idw.output = as.data.frame(idw)
names(idw.output)[1:3] <- c("long", "lat", "var1.pred")

vid.cols <- matlab::jet.colors(10)

Danum.call.density.plot <- 
  ggplot2::ggplot() + geom_tile(data = idw.output, 
                                aes(x = long, y = lat, fill = var1.pred)) + 
  #geom_point(data = interpolation.df.for.pts, aes(x = x, y = y), shape = 16, size = 3, colour = "black") + 
  geom_label(data=interpolation.df.for.pts, mapping=aes(x=x, y=y, label=name), size=4) +
  scale_fill_gradientn(colors = vid.cols) + xlab("Longitude") + ylab("Latitude") + theme_bw() + theme(panel.grid.major = element_blank(), 
                                                            panel.grid.minor = element_blank()) + theme(axis.text.x = element_text(size = 14)) + 
  theme(axis.text.y = element_text(size = 12)) + theme(axis.title.y = element_text(size = 12)) + 
  theme(axis.text.x = element_text(size = 12)) + theme(axis.title.x = element_text(size = 12)) + 
  theme(axis.title.x = element_text(size = 12)) + guides(fill = guide_legend(title = "Danum detections \n per hour")) + 
  theme(legend.text = element_text(size = 12)) + theme(legend.title = element_text(size = 12))

Danum.call.density.plot

# Jahoo  ------------------------------------------------------------

TempImagesJahoo <- list.files("/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Images/TP")
TempImagesJahoo <- str_split_fixed(TempImagesJahoo,pattern = '_',n=5)
recorder <- TempImagesJahoo[,2]
date <- TempImagesJahoo[,4]
JahooTimingDF <- cbind.data.frame(recorder,date)

TempJahooFiles <-list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Selections/')
TempJahooFiles <-str_split_fixed(TempJahooFiles,pattern = '-__',n=2)[,2]
TempJahooFiles <-str_split_fixed(TempJahooFiles,pattern = '_',n=2)[,1]

JahooTable <- as.data.frame(table(TempJahooFiles))
colnames(JahooTable) <- c('Recorder','Freq')
JahooTable

# Read in GPS data
Jahoo.gps.pts <- read.csv("data/calldensityplots/JahooGPS.csv")

recorder.index <- unique(JahooTimingDF$recorder)

interpolation.df <- data.frame()
for (x in 1:length(recorder.index)) {
  index.sub <- recorder.index[x]
  gps.sub <- subset(Jahoo.gps.pts, Unit.name == as.character(index.sub))
  detects.sub <- subset(JahooTimingDF, recorder == as.character(index.sub))
  detects.sub <- detects.sub[-which(duplicated(detects.sub)),]
  new.df <- cbind.data.frame(gps.sub$Unit.name, gps.sub$Latitude, 
                             gps.sub$Longitude, nrow(detects.sub))
  colnames(new.df) <- c("name", "y", "x", "n.detect")
  TempRecRow <- subset(JahooTable,Recorder==index.sub)
  new.df$n.detect <- new.df$n.detect/TempRecRow$Freq
  
  interpolation.df <- rbind.data.frame(interpolation.df, 
                                       new.df)
}

interpolation.df.for.pts <- interpolation.df
x.range <- as.numeric(c(min(interpolation.df$x), max(interpolation.df$x)))
y.range <- as.numeric(c(min(interpolation.df$y), max(interpolation.df$y)))
sp::coordinates(interpolation.df) = ~x + y
grd <- expand.grid(x = seq(from = x.range[1], to = x.range[2], 
                           by = 1e-05), y = seq(from = y.range[1], to = y.range[2], 
                                                by = 1e-05))
sp::coordinates(grd) <- ~x + y
sp::gridded(grd) <- TRUE
idw <- gstat::idw(formula = n.detect ~ 1, locations = interpolation.df, 
                  newdata = grd)
idw.output = as.data.frame(idw)
names(idw.output)[1:3] <- c("long", "lat", "var1.pred")



Jahoo.call.density.plot <- 
  ggplot2::ggplot() + geom_tile(data = idw.output, 
                                aes(x = long, y = lat, fill = var1.pred)) + 
  #geom_point(data = interpolation.df.for.pts, aes(x = x, y = y), shape = 16, size = 3, colour = "black") + 
  geom_label(data=interpolation.df.for.pts, mapping=aes(x=x, y=y, label=name), size=4) +
  scale_fill_gradientn(colors = vid.cols) +  xlab("Longitude") + ylab("Latitude") + theme_bw() + theme(panel.grid.major = element_blank(), 
                                                            panel.grid.minor = element_blank()) + theme(axis.text.x = element_text(size = 14)) + 
  theme(axis.text.y = element_text(size = 12)) + theme(axis.title.y = element_text(size = 12)) + 
  theme(axis.text.x = element_text(size = 12)) + theme(axis.title.x = element_text(size = 12)) + 
  theme(axis.title.x = element_text(size = 12)) + guides(fill = guide_legend(title =  "Jahoo detections \n per hour")) + 
  theme(legend.text = element_text(size = 12)) + theme(legend.title = element_text(size = 12))

Jahoo.call.density.plot

pdf(file='CallDensityPlot.pdf', height =12, width=10)
cowplot::plot_grid(Danum.call.density.plot,
                   Jahoo.call.density.plot,nrow=2)
graphics.off()



# Calculate precision -----------------------------------------------------

TruePositives <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Images/TP')
FalsePositives <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/KSWS/Images/FP')

TempTP <- str_split_fixed(TruePositives,pattern = '.wav',n=2)[,2]
TempTPProb <- str_split_fixed(TempTP,pattern = '_',n=4)[,3]
#TempTP <- TempTP[which(TempTPProb >= 0.9)]

TempFP <- str_split_fixed(FalsePositives,pattern = '.wav',n=2)[,2]
TempFPProb <- str_split_fixed(TempFP,pattern = '_',n=4)[,3]
#TempFP <- TempFP[which(TempFPProb >= 0.9)]

1- length(TempFP)/ (length(TempTP)+length(TempFP))

TruePositives <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/ImagesOver90/TP')
FalsePositives <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutputV2/Danum/ImagesOver90/FP')

TempTP <- str_split_fixed(TruePositives,pattern = '.wav',n=2)[,2]
TempTPProb <- str_split_fixed(TempTP,pattern = '_',n=4)[,3]
#TempTP <- TempTP[which(TempTPProb >= 0.9)]

TempFP <- str_split_fixed(FalsePositives,pattern = '.wav',n=2)[,2]
TempFPProb <- str_split_fixed(TempFP,pattern = '_',n=4)[,3]
#TempFP <- TempFP[which(TempFPProb >= 0.9)]

1- length(TempFP)/ (length(TempTP)+length(TempFP))

