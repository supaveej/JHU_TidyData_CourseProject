source("projUtils.R") ## utils R file created for this project

# Download the zip files and unzip the files into your working directory
print("Downloading zip file...")
fpath="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fpath,"dataset.zip",method="curl")
print("Unzipping zip file...")
unzip("dataset.zip")

# Load all applicable files: files with "train" or "test" in the name and
# an extension of ".txt"
files <- c()
for(datatype in datatypes){ 
  files <- c(files,paste0("./",datatype,"/",list.files(pattern="\\.txt$", 
                              path=paste0("./",datatype))))
}

# Import all of the files into a list of tables and extracts only
# measurments on mean and standard deviation
tables <- lapply(files,importTable)

# Combine the tables into one table
accelerometerData <- combineTables(tables)

# Replace activity ids with descriptive activity labels
accelerometerData <- getActivityLabels(accelerometerData)

# Update column names to be descriptive and easily understandable
colnames(accelerometerData) <- updatedColumnNames(colnames(accelerometerData))

# Create average table which takes the mean of the combined dataset
# and is grouped by activity and subject
avgAccelerometerData <-createAvgByActivityandSubject(accelerometerData)

# Clean update environment variables
print("Cleaning up environment variables...")
rm(list=ls()[!ls() %in% c("accelerometerData","avgAccelerometerData")])