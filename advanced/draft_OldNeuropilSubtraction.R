test=fread('Z:/Nerea/2 photon imaging/new baselines/MatLab analysis 2nd cohort/NereaMASTERupdated_Neuropil.csv')


setnames(masterDataN, old=c('value', 'Neuropilvalue', 'NeuropilSubvalue'), new=c('valueLocal', 'NeuropilvalueLocal', 'NeuropilSubvalueLocal'))
test<-test[,-c('correctedCellID','NeuropilSubvalue','rowName','value')]

temp<-merge(masterDataN, test, by=c('geno','timeFromRefStim','RefStim','sID','whiskImage','whiskStim','session','depth','timeStamp', 'stimParam','whiskStimImageType'))
test$depth<-as.character(test$depth)


tempNeuropil[,-c('date')]
temp<-merge(tempNeuropil, masterDataN, by=c('sID','whiskImage','whiskStim','session',
                                     'depth','timeStamp', 'stimParam'))
tempNeuropil$timeStamp<-as.numeric(tempNeuropil$timeStamp)
temp$SubLocaltoNeuropilOld<-temp$valueLocal-temp$Neuropilvalue
fwrite(temp, 'NereaMASTERupdated_NeuropilGavinHypoSUB.csv')


unique(test)
temp[!duplicated(temp$valueLocal)]