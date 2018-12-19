
# CodeBook for Getting and Cleaning Data

## Data Tables

### accelerometerData

Please see: [a relative link](codebook_accelerometerData.html)

### avgAccelerometerData

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
