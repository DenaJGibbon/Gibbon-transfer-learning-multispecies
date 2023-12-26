# Load necessary libraries
library(ggplot2)
library(sp)
library(gstat)
library(stringr)


# Danum Valley ------------------------------------------------------------

TempImagesDanum <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DeploymentOutput/Danum/Images/')
TempImagesDanum <- str_split_fixed(TempImagesDanum,pattern = '_',n=4)
recorder <- TempImagesDanum[,2]
date <- TempImagesDanum[,3]
DanumTimingDF <- cbind.data.frame(recorder,date)

# Read in GPS data
danum.gps.pts <- read.csv("data/calldensityplots/DanumValleyGPS.csv")

recorder.index <- unique(DanumTimingDF$recorder)

interpolation.df <- data.frame()
for (x in 1:length(recorder.index)) {
  index.sub <- recorder.index[x]
  gps.sub <- subset(danum.gps.pts, Name == as.character(index.sub))
  detects.sub <- subset(DanumTimingDF, recorder == as.character(index.sub))
  new.df <- cbind.data.frame(gps.sub$Name, gps.sub$latitude, 
                             gps.sub$longitude, nrow(detects.sub))
  colnames(new.df) <- c("name", "y", "x", "n.detect")
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

vid.cols <- viridis::viridis(n = 2)

Danum.call.density.plot <- 
  ggplot2::ggplot() + geom_tile(data = idw.output, 
                                aes(x = long, y = lat, fill = var1.pred)) + 
  #geom_point(data = interpolation.df.for.pts, aes(x = x, y = y), shape = 16, size = 3, colour = "black") + 
  geom_text(data=interpolation.df.for.pts, mapping=aes(x=x, y=y, label=name), size=4) +
  scale_fill_gradient(low = min(vid.cols), high = max(vid.cols)) + 
  xlab("Longitude") + ylab("Latitude") + theme_bw() + theme(panel.grid.major = element_blank(), 
                                                            panel.grid.minor = element_blank()) + theme(axis.text.x = element_text(size = 14)) + 
  theme(axis.text.y = element_text(size = 12)) + theme(axis.title.y = element_text(size = 12)) + 
  theme(axis.text.x = element_text(size = 12)) + theme(axis.title.x = element_text(size = 12)) + 
  theme(axis.title.x = element_text(size = 12)) + guides(fill = guide_legend(title = "Female detections")) + 
  theme(legend.text = element_text(size = 12)) + theme(legend.title = element_text(size = 12))

Danum.call.density.plot

# Jahoo Valley ------------------------------------------------------------

TempImagesJahoo <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/WideArrayEvaluation/KSWSEvaluation/gibbonNetRoutput/Images/')
TempImagesJahoo <- str_split_fixed(TempImagesJahoo,pattern = '_',n=5)
recorder <- TempImagesJahoo[,2]
date <- TempImagesJahoo[,4]
JahooTimingDF <- cbind.data.frame(recorder,date)

# Read in GPS data
Jahoo.gps.pts <- read.csv("data/calldensityplots/JahooGPS.csv")

recorder.index <- unique(JahooTimingDF$recorder)

interpolation.df <- data.frame()
for (x in 1:length(recorder.index)) {
  index.sub <- recorder.index[x]
  gps.sub <- subset(Jahoo.gps.pts, Unit.name == as.character(index.sub))
  detects.sub <- subset(JahooTimingDF, recorder == as.character(index.sub))
  new.df <- cbind.data.frame(gps.sub$Unit.name, gps.sub$Latitude, 
                             gps.sub$Longitude, nrow(detects.sub))
  colnames(new.df) <- c("name", "y", "x", "n.detect")
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

vid.cols <- viridis::viridis(n = 2)

Jahoo.call.density.plot <- 
  ggplot2::ggplot() + geom_tile(data = idw.output, 
                                aes(x = long, y = lat, fill = var1.pred)) + 
  #geom_point(data = interpolation.df.for.pts, aes(x = x, y = y), shape = 16, size = 3, colour = "black") + 
  geom_text(data=interpolation.df.for.pts, mapping=aes(x=x, y=y, label=name), size=4) +
  scale_fill_gradient(low = min(vid.cols), high = max(vid.cols)) + 
  xlab("Longitude") + ylab("Latitude") + theme_bw() + theme(panel.grid.major = element_blank(), 
                                                            panel.grid.minor = element_blank()) + theme(axis.text.x = element_text(size = 14)) + 
  theme(axis.text.y = element_text(size = 12)) + theme(axis.title.y = element_text(size = 12)) + 
  theme(axis.text.x = element_text(size = 12)) + theme(axis.title.x = element_text(size = 12)) + 
  theme(axis.title.x = element_text(size = 12)) + guides(fill = guide_legend(title = "Female detections")) + 
  theme(legend.text = element_text(size = 12)) + theme(legend.title = element_text(size = 12))

Jahoo.call.density.plot


