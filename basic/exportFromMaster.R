# provide the directory location of the folder of interest
dir<-"Z:/Nerea/2 photon imaging/SynapticActivityneuropilTest1XROI-Cre-Rum2-GcaMP6" ; for (i in dir) { setwd(i)
  setwd(i)}

dir(dir)
# function to be loaded first#### 
library(data.table)
fileOutput<-function(dataInput, stimParamVal, sessionVal, genoVal, whiskStimImageVal, timeFromRefStimVal, RefStimNOTtoinclude='stim24' ){
  
  dataInput<-dataInput[stimParam==stimParamVal & 
                         geno %in% genoVal & 
                         session %in% sessionVal &
                         whiskStimImageType ==whiskStimImageVal & 
                         timeFromRefStim %in% timeFromRefStimVal &
                         !RefStim %in% RefStimNOTtoinclude ,] 
  
  if (nrow(dataInput)>1048570){
    print('Error: data generated too long')
    print(paste('Error: the current data set contains', nrow(dataInput)-1048570, 'too many rows'))
    print(paste('Error: the file need to be broken down into:', round(nrow(dataInput)/1048570, digits = 0)))
  }else{
    print('data are ok - saved in the directory:')
    print(getwd())
    print('with the name:')
    
    
    print(paste(stimParamVal, 'genoVal', whiskStimImageVal, timeFromRefStimVal[1], timeFromRefStimVal[length(timeFromRefStimVal)], 'NEW', '.csv', sep='_'))
    fwrite(dataInput, paste(stimParamVal, 'genoVal', whiskStimImageVal, timeFromRefStimVal[1], timeFromRefStimVal[length(timeFromRefStimVal)], 'NEW','.csv', sep='_'))       
    
    print(dataInput)
    dataInput<<-dataInput
    
  }
  
}

# ONLY USE THIS ####

masterData<-fread('NereaMasterupdated_Neuropil.csv')

fileOutput(dataInput=masterData, # name of data set to work with
           sessionVal=c('b1','b2','p1','p2'), #c('b1','b2','p1','p2','r1','r2')
           stimParamVal=c('ten'), #c('ten','five','spont')
           genoVal=c('wt','het'), #c('wt','het')
           whiskStimImageVal =c('identical'), # c('identical','different')
           #RefStimNOTtoinclude=c('stim01','stim02') #stim not to inclue eg.stim1 
           timeFromRefStimVal=seq(0,10,1) # first 2 digits correspond to the interval of interest post-stim
) 


masterData<-fread('Z:/Nerea/2 photon imaging/SynapticActivityneuropilTest1XROI-Cre-Rum2-GcaMP6/NereaMASTERupdated_Neuropil.csv')
