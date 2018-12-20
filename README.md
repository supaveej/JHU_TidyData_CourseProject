# JHU_TidyData_CourseProject
Coursera JHU Data Science Specialization: Getting and Cleaning Data in R (Course Project)

## Overview
To reproduce the tidy data set:
1. Download the following files into your working directory:
    1. projGettingAndCleaningData.R
    1. projUtils.R
2. Run the main script: projGettingAndCleaningData.R

**Please see the [CodeBook](CodeBook.md) for more details on the scripts and tidy data produced.**

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

### projUtils.R
This script contains all of the functions utilized by projGettingAndCleaningData.R. This script has the following functions, which are detailed further down in this document:
+ importTable(filepath)
+ getFeatureColumnNames()
+ getActivityLabels(table)
+ combineTables(tables)
+ updatedColumnNames(columnNames)
+ createAvgByActivityandSubject(table)
