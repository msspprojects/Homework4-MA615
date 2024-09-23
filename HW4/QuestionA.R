library(data.table)
file_root<-"https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
years_skip1<-1985:1999
df_list <- list() # create an empty list to store data
tail<- ".txt.gz&dir=data/historical/stdmet/"
for (year in years_skip1){
  path<-paste0(file_root,year,tail) # combine and create the whole URL
  # read the URL and use the first line as header
  header<-scan(path,what= 'character',nlines=1)
  # read the actual data and do not treat the first row as header
  buoy<-fread(path,header=FALSE,skip=1, fill=TRUE)
  # manually assign the header
  colnames(buoy)<-header
  df_list[[as.character(year)]] <- buoy
}
print(head(df_list))
# Combine all data into a single data.table
all_data <- rbindlist(df_list, use.names = TRUE, fill = TRUE)

# View the combined data
print(head(all_data))

