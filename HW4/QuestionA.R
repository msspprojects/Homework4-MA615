library(data.table)
library(stringr)
library(lubridate)
library(dplyr)
library(tidyr)
file_root<-"https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
years<-1985:2023
df_list <- list() # create an empty list to store data
tail<- ".txt.gz&dir=data/historical/stdmet/"
all_columns <- c("YY", "MM", "DD", "hh", "mm", "WDIR", "WSPD", "GST", "WVHT", 
                 "DPD", "APD", "MWD", "PRES", "ATMP", "WTMP", "DEWP", "VIS", 
                 "TIDE")
# Function to determine lines to skip
lines_to_skip <- function(path){
  content <- file(path, open = "r") # read the file
  first2 <- readLines(content, n = 2) # read the first two lines
  close(content)
  
  # check if the second line are all numbers
  second_line <- str_split(first2[2], "\\s+", simplify = TRUE)
  check_numeric <- str_detect(second_line, "^-?\\d*\\.?\\d+$")
  
  if (all(check_numeric)){
    return(1) # second line all numeric, only first line is header
  } else{
    return(2) # first and second lines are header
  }
}

# Function to read data in each file
read_file <- function(year){
  path<-paste0(file_root,year,tail) # combine and create the whole URL
  header<-scan(path,what='character',nlines=1)
  skip_line <- lines_to_skip(path) # determine how many lines to skip
  buoy<-fread(path,header=FALSE,skip=skip_line, fill=Inf)
  # manually assign the header
  colnames(buoy)<-header
  col_miss <- setdiff(all_columns, names(buoy))
  for (col in col_miss){
    set(buoy, j=col, value=NA)
  }
  setcolorder(buoy, all_columns)
  return(buoy)
}


for (year in years) {
  data <- read_file(year)
  df_list[[as.character(year)]] <- data
}

# Combine all the datasets into one data.table
combined_data <- rbindlist(df_list, use.names = TRUE, fill = TRUE)

# Define a function to convert two digit years into four digit years
convert_2_4 <- function(year){
  ifelse(year < 100, ifelse(year<25, 2000+year, 1900+year), year)
}

# convert the 2 digit year to 4 digit year and combine three columns describing year 
combined_data <- combined_data %>% 
  mutate(YY=convert_2_4(YY))%>% 
  mutate(YYYY = coalesce(YYYY, `#YY`, YY)) %>% 
  select(-`#YY`, -YY) %>% select(YYYY, everything())

# create a proper datetime column
combined_data <- combined_data %>%
  mutate(
    new_mm = replace_na(mm, 0),
    DateTime = make_datetime(year = YYYY, month = MM, day = DD, 
                             hour = hh, min = new_mm, 
                             tz = "America/New_York")
  ) %>% select(-new_mm, -YYYY, -MM, -DD, -hh, -mm) %>%
  select(DateTime, everything())


# View the first few rows of the combined dataset
print(head(combined_data))

