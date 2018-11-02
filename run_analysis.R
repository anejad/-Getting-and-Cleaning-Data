# Step 1: Download files and Unzip files -------

# 1.A) Downloading the file:
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

#1.B) unzip the zip file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#1.C) get the file list
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)

# Step 2: Read the csv data -------
# The dataset includes the following files:
# 'README.txt'
# 
# 'features_info.txt': Shows information about the variables used on the feature vector.
# 
# 'features.txt': List of all features.
# 
# 'activity_labels.txt': Links the class labels with their activity name.
# 
# 'train/X_train.txt': Training set.
# 
# 'train/y_train.txt': Training labels.
# 
# 'test/X_test.txt': Test set.
# 
# 'test/y_test.txt': Test labels.

#2.A) Read the Activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

#2.B) Read the Subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#2.C) Read Fearures files
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

#Step 3: Merges the training and the test sets to create one data set.

#3.A) Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#3.B) Assign names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#3.C) Merge columns to get the data frame Data for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

# Step 4) Uses descriptive activity names to name the activities in the data set

# 4.A) Subset Name of Features by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#4.B) Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#4.C)Read descriptive activity names from “activity_labels.txt”

activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)


#Step 5:  Names of Feteatures will labelled using descriptive variable names.

# 5.A) prefix t is replaced by time
names(Data)<-gsub("^t", "time", names(Data))
# 5.B) Acc is replaced by Accelerometer
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
# 5.C) Gyro is replaced by Gyroscope
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
# 5.D) prefix f is replaced by frequency
names(Data)<-gsub("^f", "frequency", names(Data))
# 5.E) Mag is replaced by Magnitude
names(Data)<-gsub("Mag", "Magnitude", names(Data))
# 5.F) BodyBody is replaced by Body
names(Data)<-gsub("BodyBody", "Body", names(Data))

#Step 6: Create Tiday data spread sheet
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
print(Data2)