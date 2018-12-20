library(dataMaid)

updateColName <- function(colName){
  if(grepl("_Mean.*",colName)) {
    colName <- paste("Mean of the",sub("_Mean","",colName))
  }
  if(grepl("_StandardDeviation.*",colName)) {
    colName <- paste("Standard Devation of the", sub("_StandardDeviation","",colName))
  }
  return(colName)
}

createCodebook <- function(table, ...){
  columnNames <- colnames(table)
  columnNames <- sub("^frequency_","Frequency of ",columnNames)
  columnNames <- sub("^time_","Time of ",columnNames)
  columnNames <- sub("BodyGyroJerkMagnitude","Body Gyro Jerk Magnitude",columnNames)
  columnNames <- sub("BodyGyroMagnitude","Body Gyro Magnitude",columnNames)
  columnNames <- sub("BodyAcceleration","Body Acceleration",columnNames)
  columnNames <- sub("JerkMagnitude","Jerk Magnitude ",columnNames)
  columnNames <- sub("BodyGyroJerk","Body Gyro Jerk",columnNames)
  columnNames <- sub("BodyGyro","Body Gyro",columnNames)
  columnNames <- sub("BodyAcceleration","Body Acceleration",columnNames)
  columnNames <- sub("GravityAcceleration","Gravity Acceleration",columnNames)
  columnNames <- sub("JerkMagnitude","Jerk Magnitude ",columnNames)
  columnNames <- sub("_Jerk"," Jerk ",columnNames)
  columnNames <- sub("_X"," (X Dimension)",columnNames)
  columnNames <- sub("_Y"," (Y Dimension)",columnNames)
  columnNames <- sub("_Z"," (Z Dimension)",columnNames)
  columnNames <- sub("datatype","DataType (test, train)",columnNames)
  columnNames <- sub("subject","Subject ID",columnNames)
  columnNames <- sub("activity","Activity",columnNames)
  columnNames <- lapply(columnNames,updateColName)
  
  i <- 1
  for (item in colnames(table)){
    attr(table[[item]],"shortDescription") <- columnNames[i]
    i <- i+1
  }
  
  makeCodebook(table, replace=TRUE, ...)
}

createCodebook(avgAccelerometerData, reportTitle="Codebook for avgAccelerometerData", 
               file="codebook_avgAccelerometerData.Rmd", mode=c("summarize"))
createCodebook(accelerometerData, reportTitle="Codebook for accelerometerData", 
               file="codebook_accelerometerData.Rmd", mode=c("summarize"))

