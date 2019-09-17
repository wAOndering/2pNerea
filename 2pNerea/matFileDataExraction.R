# load the tools necessary for analysis
library.list<-c('ggplot2','reshape2','R.matlab','tools','plyr','data.table')
lapply(library.list, require, character.only = TRUE)

#### MASTER DATA GENERATION ####
# provide the directory location of the folder of interest
dir<-"Z:/Nerea/2 photon imaging/SynapticActivityneuropilTest1XROI-Cre-Rum2-GcaMP6" ; for (i in dir) { setwd(i)
        setwd(i)}

# list and select the files to be working on
files<-list.files(pattern='.mat', recursive = TRUE)
files<-files[grep("analysis-", files)]
#toExclude<-c(272) # files to exclude based on error in length (time smasterData)
#files<- files[-toExclude]

# to recover the information about the area for each segmentation
areaFiles<-list.files(pattern='*-area.csv', recursive = TRUE)
areaComb<-list()
for (i in areaFiles){
  areaFiles <- fread(i)
  areaFiles$fileName<-i
  areaComb[[i]]<-areaFiles
  print(paste(which(areaFiles == i) , "/", length(areaFiles), " - file:", basename(i)))
}
areaComb<-rbindlist(areaComb)
areaComb[, c("sID", "stim", "date", "file") := tstrsplit(fileName, "/", fixed=TRUE)]
areaComb[, c("sID", "stim", "date", "file") := tstrsplit(fileName, "/", fixed=TRUE)]
areaComb[, c("timeStamp") := sub("X",'',variable)][, variable := NULL]
areaComb[, c("whiskStim", "stim", "whiskImage", "area", "session","animal") := tstrsplit(stim, " ", fixed=TRUE)] # the way the labeling work is [whiskStim stim] and then ref to the [whiskImage]
areaComb[, c("date","animal1") := tstrsplit(date, " ", fixed=TRUE)]
areaComb[, c("file") := sub("Segmentation-1",'',file)]
areaComb[, c("file") := sub("_001-area.csv",'',file)]
areaComb[, c("stimParam", "depth") := tstrsplit(file, "(?<=[A-Za-z])(?=[0-9])", perl=TRUE)]
areaComb[whiskStim==whiskImage, c('whiskStimImageType'):='identical']
areaComb[!whiskStim==whiskImage, c('whiskStimImageType'):='different']
areaComb=areaComb[areaComb$segId != 0, ]
areaComb<-rename(areaComb, c(segId='rowName'))
areaComb<-areaComb[,c('rowName', 'areaPx', 'sID', 'whiskStim', 'whiskImage', 'depth', 'whiskStimImageType')]
areaComb$rowName<-as.character(areaComb$rowName)

# make a master list that include all the data
masterData<-list()
for (i in files){
        mat<-readMat(i)
        mat<-data.frame(mat[[1]][11])
        mat$rowName<-rownames(mat)
        mat$fileName<-i
        masterData[[i]]<-mat
        print(paste(which(files == i) , "/", length(files), " - file:", basename(i)))
}

# data manipulation of the list to extract important information
masterData<-rbindlist(masterData)
masterData<-melt(masterData, id=c('rowName','fileName'))
masterData[, c("sID", "stim", "date", "file") := tstrsplit(fileName, "/", fixed=TRUE)]
masterData[, c("timeStamp") := sub("X",'',variable)][, variable := NULL]
masterData[, c("whiskStim", "stim", "whiskImage", "area", "session","animal") := tstrsplit(stim, " ", fixed=TRUE)] # the way the labeling work is [whiskStim stim] and then ref to the [whiskImage]
masterData[, c("date","animal1") := tstrsplit(date, " ", fixed=TRUE)]
masterData[, c("file") := sub("analysis-1",'',file)]
masterData[, c("file") := sub("_001.mat",'',file)]
masterData[, c("stimParam", "depth") := tstrsplit(file, "(?<=[A-Za-z])(?=[0-9])", perl=TRUE)]
masterData[whiskStim==whiskImage, c('whiskStimImageType'):='identical']
masterData[!whiskStim==whiskImage, c('whiskStimImageType'):='different']

masterDataN<-masterData[,-c('animal1','stim','animal','area','file','fileName','date')][]

# generate the pattern of interest to create and analyze time points arond stimulation
# data genearted for 1200 points corresponding to 120 sec each point is equivalent to 100ms in the time serie

# for stimulation ten the pattern of stimulation are as follow
stimTen<-c(11,67,123,180,235,292,348,404,460,516,573,629,685,741,797,854,910,966,1022,1078,1135)
# IMPORTANT note the last stim is at 1191 so can not be analyzed and removed from stim list thus could be removed to have only 21 stim
stimIDTen<-data.table(sapply(stimTen, function(x) seq(x-10,x+40))) # in this case everything is centered at stim 0 baseline from 0 to -5 and poststim
stimIDTen$timeFromRefStim<-as.numeric(rownames(stimIDTen))-11
stimIDTen<-melt(stimIDTen, id="timeFromRefStim")
stimIDTen$variable<-gsub("V","stim", stimIDTen$variable)
colnames(stimIDTen)<-c("timeFromRefStim","RefStim","timeStamp")
stimIDTen$stimParam<-'ten'
stimIDTen[, c('stim','stimOrder') := tstrsplit(RefStim, "(?<=[A-Za-z])(?=[0-9])", perl=TRUE)]
stimIDTen$stimOrder<-formatC(as.numeric(stimIDTen$stimOrder), width = 2, flag = "0")
stimIDTen$RefStim<-paste(stimIDTen$stim, stimIDTen$stimOrder, sep='')
stimIDTen<-stimIDTen[,1:4]

#for stimualtion five the pattern of stimulation are as follow
stimFive<-c(11,113,215,318,420,522,625,727,829,932,1034,1136)
# IMPORTANT note the last stim is at 1191 so can not be analyzed and removed from stim list thus could be removed to have only 21 stim
stimIDFive<-data.table(sapply(stimFive, function(x) seq(x-10,x+40))) # in this case everything is centered at stim 0 baseline from 0 to -5 and poststim
stimIDFive$timeFromRefStim<-as.numeric(rownames(stimIDFive))-11
stimIDFive<-melt(stimIDFive, id="timeFromRefStim")
stimIDFive$variable<-gsub("V","stim", stimIDFive$variable)
colnames(stimIDFive)<-c("timeFromRefStim","RefStim","timeStamp")
stimIDFive$stimParam<-'five'
stimIDFive[, c('stim','stimOrder') := tstrsplit(RefStim, "(?<=[A-Za-z])(?=[0-9])", perl=TRUE)]
stimIDFive$stimOrder<-formatC(as.numeric(stimIDFive$stimOrder), width = 2, flag = "0")
stimIDFive$RefStim<-paste(stimIDFive$stim, stimIDFive$stimOrder, sep='')
stimIDFive<-stimIDFive[,1:4]

# create a common stimID dataset
stimID<-rbind(stimIDTen,stimIDFive)

# working on the correspondance table to have matching and corrected cell identification #
# cellID<-fread('sIDMASTER.csv')
# cellID<-cellID[, c('correctedCellID') := rownames(cellID), by=c('sID','whiskImage','depth')]
# cellID<-melt(cellID, id=c('sID','whiskImage','depth','correctedCellID'))
# cellID$variable<-as.character(cellID$variable)
# cellID[, c("temp","session") := tstrsplit(variable, "_", fixed=TRUE)][, c('temp','variable') := NULL][]
# cellID<-rename(cellID, c(value='rowName')) #rowName correspond to the orginal cell identification
# cellID$sID<-formatC(cellID$sID, width = 3, flag="0")
# cellID$depth<-formatC(cellID$depth, width = 3, flag="0")
# cellID<-cellID[, lapply(.SD, as.character)]
# fwrite(cellID, 'sIDMASTERtransform.csv')

# merging with ID to identify the areas size
masterDataN<-merge(masterDataN, areaComb, by=c('rowName','sID', 'whiskStim', 'whiskImage', 'depth', 'whiskStimImageType'))

# merging master data with stimulation stimID
masterDataN$timeStamp<-as.numeric(masterDataN$timeStamp)
masterDataN<-merge(masterDataN, stimID, by=c('timeStamp','stimParam'), all=TRUE)

# merging master data with cellID
# masterDataN<-merge(masterDataN, cellID, by=c('sID','whiskImage','session','depth','rowName'))

# merging data to genotype
#geno<-c('wt','wt','het','het','het','het','wt','wt','het','het')
#sID<-unique(masterDataNew1$sID)
sIDgeno<-fread('Animals.csv')
sIDgeno$sID<-as.character(sIDgeno$sID)
masterDataN<-merge(masterDataN, sIDgeno, by='sID')

# write master file in the working directory
fwrite(masterDataN, 'NereaMASTERupdated.csv')