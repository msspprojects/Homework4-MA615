library(data.table)
file_root<-"https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
years<-1985:2023
df_list <- list() # create an empty list to store data
tail<- ".txt.gz&dir=data/historical/stdmet/"
for (year in years){
  path<-paste0(file_root,year,tail)
  header<-scan(path,what= 'character',nlines=1)
  buoy<-fread(path,header=FALSE,skip=2)
  colnames(buoy)<-header
}

