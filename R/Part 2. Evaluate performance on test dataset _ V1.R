library(gibbonNetR)
library(dplyr)

ModelRunsList <- list.files('/Volumes/DJC Files/MultiSpeciesTransferLearning/DataAugmentation/modelruns_earlystoponly',
           full.names = T)


CombinedResultsDF <- data.frame()

for(a in 1:length(ModelRunsList)){
  
  ModelRunFiles <- list.files(ModelRunsList[a],full.names = T)
  PerformanceDir <- ModelRunFiles[str_detect(ModelRunFiles,'performance_tables')]
  AllFiles <- list.files(PerformanceDir,full.names = T)
  ListDFs <- lapply(AllFiles, read.csv)
  CombinedDFs <- do.call(rbind,ListDFs)
  
  CombinedResultsDF <-rbind.data.frame(CombinedResultsDF,CombinedDFs)
  
}

head(CombinedResultsDF)
as.factor(CombinedResultsDF$Training.Data)
CombinedResultsDF$Training.Data <- plyr::revalue(CombinedResultsDF$Training.Data,c("Danum copy" = "Danum \n Replicated",
                                            "Danum" = "Danum \n Original",
                                            "DanumClipsSorted_AugmentedCropping"= "Danum \n Cropped",
                                            "DanumClipsSorted_AugmentedNoise"= "Danum \n Noise Added"))




CombinedResultsDF$N.epochs <- as.factor(CombinedResultsDF$N.epochs)

CombinedResultsDF$Threshold <- as.factor(CombinedResultsDF$Threshold)
CombinedResultsDF <- na.omit(CombinedResultsDF)
# Calculate mean value for each algorithm, training data, and probability threshold
performance.dfF1 <- CombinedResultsDF %>% 
  group_by(Training.Data,CNN.Architecture,Frozen) %>%
  summarize(
    F1 = max(F1),
    AUC = median(AUC),
    sd = sd(F1),
    sdAUC = sd(AUC),
  )

# Convert training data to factor
performance.dfF1$Training.Data <- as.factor(performance.dfF1$Training.Data )
performance.dfF1$CNN.Architecture.FT <- as.factor(paste(performance.dfF1$CNN.Architecture, performance.dfF1$Frozen, sep='_'))

# If FALSE means no fine-tuning (transfer learning)

ggboxplot(data=performance.dfF1,
       x='Training.Data',y='AUC',fill='Frozen',
       facet.by = 'CNN.Architecture.FT')+ ylim(0.5,1)+
        scale_fill_manual(values= matlab::jet.colors(length(unique(performance.dfF1$Frozen))) )

ggboxplot(data=performance.dfF1,
          x='Training.Data',y='F1',fill='Frozen',
          facet.by = 'CNN.Architecture.FT')+
  scale_fill_manual(values= matlab::jet.colors(length(unique(performance.dfF1$Frozen))) )



# Calculate mean value for each algorithm, training data, and probability threshold
performance.dfF1Threshold <- CombinedResultsDF %>% 
  group_by(Threshold,Training.Data,CNN.Architecture,Frozen) %>%
  summarize(
    F1 = max(F1),
    AUC = median(AUC),
    sd = sd(F1),
    sdAUC = sd(AUC),
  )

# Convert training data to factor
performance.dfF1Threshold$Training.Data <- as.factor(performance.dfF1Threshold$Training.Data )
performance.dfF1Threshold$CNN.Architecture.FT <- as.factor(paste(performance.dfF1Threshold$CNN.Architecture, performance.dfF1Threshold$Frozen, sep='_'))


# Create plot
ggline(data=performance.dfF1Threshold,
       x='Threshold',y='F1',group  = 'Training.Data',color='Training.Data',
       facet.by = 'CNN.Architecture.FT')+
  scale_color_manual(values= matlab::jet.colors(length(unique(performance.dfF1Threshold$Training.Data))) )+
  ylab('F1 score')+ylim(0.75,1)+geom_hline(yintercept = max(performance.dfF1Threshold$F1),lty='dashed')+
  geom_errorbar(aes(ymin = F1 - sd, ymax = F1 + sd), width = 0.1)


