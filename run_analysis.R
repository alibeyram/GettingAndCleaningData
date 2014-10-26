# For the purposes of this project, the files in the Inertial Signals folders are not needed.

#Reading the files

SubjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
XTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
YTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")

SubjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
XTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
YTest <- read.table("./UCI HAR Dataset/test/y_test.txt")


#Merges the training and the test sets to create one data set

Subject <- rbind(SubjectTest,SubjectTrain)
X <- rbind(XTest,XTrain)
y <- rbind(YTest,YTrain)

df <- cbind(Subject,y,X)

rm(list=ls()[ls()!='df'])
features <- read.table("./UCI HAR Dataset/features.txt",colClasses = c("character","character"))
featuresName <- features[,2]

#Remove extra dashes and BodyBody naming error from original feature names

featuresName <- gsub("^t", "Time", featuresName)
featuresName <- gsub("^f", "Frequency",featuresName)
featuresName <- gsub("-mean\\(\\)", "Mean", featuresName)
featuresName <- gsub("-std\\(\\)", "StdDev", featuresName)
featuresName <- gsub("-", "", featuresName)
featuresName <- gsub("BodyBody", "Body", featuresName)

colnames(df)<- c("Subject","ActivityNum",featuresName)


#Uses descriptive activity names to name the activities in the data set


locations <- grep("(Mean|StdDev)", names(df))

df<- df[,c(1,2,locations)]



ActivityNames <- read.table("./UCI HAR Dataset/activity_labels.txt")
colnames(ActivityNames) <- c("ActivityNum","Activity_Description")

df <- merge(ActivityNames,df,by="ActivityNum")
df <- df [,-1]
head(df[,1:6])

#independent tidy data set with the average of each variable for each activity and each subject.

library(plyr)

newColMeans <- function(data) { colMeans(data[,-c(1,2)]) }

tidyMeans <- ddply(df, .(Subject, Activity_Description), newColMeans)
names(tidyMeans)[-c(1,2)] <- paste0("Average-", names(tidyMeans)[-c(1,2)])
head(tidyMeans[,1:6])


write.table(tidyMeans, "tidyMeans.txt", row.names = FALSE)