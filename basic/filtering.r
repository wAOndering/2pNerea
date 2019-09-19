sterData = fread( master.csv)
newtab = sterData[sterData$areaPx >= 2000 &  sterData$areaPx = 5000, ]
fwrite(newtab, 'Z:/Nerea/2 photon imaging/SynapticActivityneuropilTest1XROI-Cre-Rum2-GcaMP6/MyNewTab.csv')

areaComb[areaComb$sID == 113 & depth == 100, ]
masterDataN[areaComb$sID == 113 & depth == 100 &, ]
masterDataN[areaComb$sID == 113 & depth == 100 & session == 'b1' & timeStamp == 1 , ]