
# CodeBook for Getting and Cleaning Data

## Overview

### Orignal Data Source and Information
**Data:** [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

**ReadMe File:** [README.txt](README.txt)


### projGettingAndCleaningData.R

This is the main script used to generate the tidy data set in this analysis. The script performs the following tasks:
+ sources projUtils.R file
+ downloads the zip files and unzip the files into your working directory
+ loads and imports all of the data files for the training and test sets
+ extracts only the mean and standard deviations on measurements into the imported tables
+ combines all the tables into one table
+ replaces activity ids with descriptive activity labels
+ updates column names to be descriptive and easily understandable
+ creates average table which takes the mean of the combined dataset and is grouped by activity and subject
+ cleans update environment variables


```R
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
  files <- c(files,paste0("./UCI HAR Dataset/",datatype,"/",list.files(pattern="\\.txt$", 
                              path=paste0("./UCI HAR Dataset/",datatype))))
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
```

### projUtils.R

This script contains all of the functions utilized by projGettingAndCleaningData.R. This script has the following functions, which are detailed further down in this document:
+ importTable(filepath)
+ getFeatureColumnNames()
+ getActivityLabels(table)
+ combineTables(tables)
+ updatedColumnNames(columnNames)
+ createAvgByActivityandSubject(table)

## Data Tables

### accelerometerData

For the codebook for this table please see: 
[Codebook for Accelerometer Data](cb_accelerometerData.pdf)

### avgAccelerometerData

For the codebook for this table please see: 
[Codebook for Average Accelerometer Data](cb_avgAccelerometerData.pdf)

## Functions

### projUtils :: importTable(filepath)

This function does the following:
* input: filepath of files
* imports the file into a table
* sets the column names
* adds a column for the datatype (train/test)
* returns the table


```R
importTable <- function(filepath){
  print(paste("Importing file:",filepath,"..."))
  
  # import the file into a table
  datatype <- str_extract(filepath,"train|test")
  tablename <- str_match(filepath,".+/(.+)_.+")[2]
  table <- read.table(filepath)
  
  # for X (feature) files, load feature column names into
  #   the table and tuncate the table to only include measurements of
  #   Mean and Standard Deviation
  # for other files, rename the column based on the file
  #   name (e,g., y, subject, etc.)
  if(tablename=="X"){
    colnames(table) <- getFeatureColumnNames()
    table <- table[,c(grepl("([Mm]ean\\(\\)|std\\(\\))",colnames(table)))]
  }
  else {
    colnames(table) <- c(tablename)
  }
  
  # add a column for the datatype to the table
  table$datatype  <- datatype

  # return the table
  return(as_tibble(table))
}
```

### projUtils :: getFeatureColumnNames()

This function does the following:
* loads feature column names if not loaded; otherwise get from cache
* returns the list of feature column names


```R
getFeatureColumnNames <- function(){
  if(!is.null(featurenames)){
    print("Using cached feature labels...")
    return(featurenames)
  }
  else {
    print("Loading feature labels...")
    featurenames <- read.table("./features.txt")
    featurenames <-(featurenames[,2])
    featurenames <- c(levels(featurenames)[featurenames])
    return(featurenames)
  }
}
```

### projUtils :: getActivityLabels(table)

This function does the following:
* input: table containing combined data
* loads id and activity label mappings
* updates activity id to activity label in table
* returns updated table with activity label


```R
getActivityLabels <- function(table){
  print("Loading activity labels...")
  
  activities <- read.table("./activity_labels.txt")
  colnames(activities) <- c("id","activity")
  table$y <-
    activities[match(table$y, activities$id),'activity']
  return(table)
}
```

### projUtils :: combineTables(tables)

This function does the following:
* input: list of tables to combine
* combines test tables by appending columns
* combines training tables by appending columns
* returns a combined table of test and training data


```R
combineTables <- function (tables){
  print("Combining tables into one data set...")
  
  i <- 1
  tabletest <- NULL
  tabletrain <- NULL
  
  for(table in tables){
    # combine test tables by appending columns
    if(table$datatype[1] == datatypes[1]){
      tabletest <- if(is.null(tabletest)) table else 
        cbind(tabletest,table[,-ncol(table)])
    }
    else {
      # combine training tables by appending columns
      tabletrain <- if(is.null(tabletrain)) table else 
        cbind(tabletrain,table[,-ncol(table)])
    }  
    i <- i+1
  }
  
  # return a combined table of test and training data
  return(as_tibble(rbind(tabletrain,tabletest)))
}
```

### projUtils :: updatedColumnNames(columnNames)

This function does the following:
* input: list of column names
* cleans up column names to be more descriptive


```R
updatedColumnNames <- function(columnNames){
  print("Cleaning up column names...")
  
  columnNames <- sub("^f","frequency_",columnNames)
  columnNames <- sub("^t","time_",columnNames)
  columnNames <- sub("BodyAcc","BodyAcceleration_",columnNames)
  columnNames <- sub("GravityAcc","GravityAcceleration_",columnNames)
  columnNames <- sub("Mag","Magnitude_",columnNames)
  columnNames <- sub("mean\\(\\)","Mean",columnNames)
  columnNames <- sub("std\\(\\)","StandardDeviation",columnNames)
  columnNames <- gsub("-","_",columnNames)
  columnNames <- gsub("__","_",columnNames)
  columnNames <- sub("BodyBody","Body",columnNames)
  columnNames[columnNames=="y"] <- "activity"
  return(columnNames)
}
```

### projUtils :: createAvgByActivityandSubject(table)

This function does the following:
* input: table for accelerometer data
* creates a tidy data set with the average of each variable
* for each activity and subject


```R
createAvgByActivityandSubject <- function(table){
  print("Creating summary table by activity and subject...")
  
  avgtable <- table %>%
    group_by(activity, subject, datatype) %>%
    summarize_at(seq(3,ncol(table)-1,1),mean)
  return (avgtable)
}
```
