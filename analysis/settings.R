DATA_PATH <- "../data/"
COMPUTED_OBJECTS_PATH <- "../data/"

GetData <- function(csv_file){
    if (file.exists(paste0(COMPUTED_OBJECTS_PATH, csv_file))) {
        read.csv(paste0(COMPUTED_OBJECTS_PATH, csv_file))
    } else{
        read.csv(paste0(DATA_PATH, csv_file))
    }
}

source("jjh_misc.R")

