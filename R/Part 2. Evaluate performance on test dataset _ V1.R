library(gibbonNetR)
library(plyr)

ModelRunsList <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/modelruns',
           full.names = T)


CombinedResultsDF <- data.frame()

for(a in 1:length(ModelRunsList)){
  
  ModelRunFiles <- list.files(ModelRunsList[a],full.names = T)
  PerformanceDir <- ModelRunFiles[str_detect(ModelRunFiles,'performance_tables')]
  
  Output <- get_best_performance(performancetables.dir=PerformanceDir,
                       model.type = 'binary',Thresh.val = 0)
  
  TempBestF1 <- as.data.frame(Output$best_f1)
  CombinedResultsDF <-rbind.data.frame(CombinedResultsDF,TempBestF1)
  
}

head(CombinedResultsDF)

CombinedResultsDF$`Training Data` <- revalue(CombinedResultsDF$`Training Data`,c("Danum copy" = "Danum \n Replicated",
                                            "Danum" = "Danum \n Original",
                                            "DanumClipsSorted_AugmentedCropping"= "Danum \n Cropped",
                                            "DanumClipsSorted_AugmentedNoise"= "Danum \n Noise Added"))




CombinedResultsDF$`N epochs` <- as.factor(CombinedResultsDF$`N epochs`)

ggboxplot(data=CombinedResultsDF,x='Training Data',y = 'F1',#color ="N epochs",
            facet.by = "CNN Architecture") + ylim(0,1)

ggboxplot(data=CombinedResultsDF,x='Training Data',y = 'AUC',#color ="N epochs",
            facet.by = "CNN Architecture") + ylim(0.5,1)

