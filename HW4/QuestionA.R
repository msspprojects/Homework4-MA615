file_root<-"https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
year<-"2023"
tail<- ".txt.gz&dir=data/historical/stdmet/"
path<-paste0(file_root,year,tail)
header=scan(path,what= 'character',nlines=1)
buoy<-fread(path,header=FALSE,skip=2)
colnames(buoy)<-header