# GPS points
library(gpx)

GPSList <- list.files('data/GPSData/', full.names = T)

Sites <- c('Danum Training','Danum Wide Array',
           'Jahoo Training', 'Jahoo Wide Array',
           'Maliau Basin Test','Vietnam Test')

CombinedGPSDataFrame <- data.frame()

for(a in 1:length(GPSList)){
 TempFrame <-  gpx::read_gpx(GPSList[a])
 TempFrame <- TempFrame$waypoints
 TempFrame <- TempFrame[,c('Latitude','Longitude','Elevation')]
 TempFrame$Site <- Sites[a]
 CombinedGPSDataFrame <- rbind.data.frame(CombinedGPSDataFrame,TempFrame)
}

head(CombinedGPSDataFrame)
