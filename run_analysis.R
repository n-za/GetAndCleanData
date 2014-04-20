## Emits a warning when the file does not exist
## return 1 in the error case and 0 otherwise
CheckFile  <- function(filename) {
  if (!file.exists(filename)) {
    warning(sprintf("Directory or File %s does not exist.", filename))
    1       
  } else {
    0
  }
}
## Checks wether the current directory contains all the subdirectories and file neeeded.
## returns the number of missing objects (file or dir)
## at the exit the current directory is the same at the entry
SanityCheck <- function() {
  ret <- 0 # number of missing files
  ret <- ret + sum(sapply(c("features_info.txt", "features.txt", "activity_labels.txt", "test", "train"), 
                          CheckFile))
  setwd("test")
  ret <- ret + sum(sapply(c("X_test.txt", "subject_test.txt", "y_test.txt"), 
                          CheckFile))
  setwd("..")
  setwd("train")
  ret <- ret + sum(sapply(c("X_train.txt", "subject_train.txt", "y_train.txt"), 
                          CheckFile))
  setwd("..")
  ret            
}
## ReadOnePart load the contents of the directory defined by suffix (either test or train)
## actlabel is a data.frame containing the labels for the activities
## actlabel[,1] is the level of the factor
## acrlabel[,2] is the label of the factor
## returns a data.frame whose 1st column is the dir name, the 2nd the activity, 
## the sequel contains all the remaining 561 variables
ReadOnePart <- function(suffix, actlabel) {
  setwd(suffix)
  df <- read.table(sprintf("X_%s.txt", suffix), colClasses = c("numeric"))
  subject <- read.table(sprintf("subject_%s.txt", suffix), colClasses = c("factor"))
  y <- read.table(sprintf("y_%s.txt", suffix), colClasses = c("factor"))
  y <- factor(y[,1], levels = sapply(actlabel[,1], as.character), labels = actlabel[,2])
  setwd("..")  
  cbind(suffix, y, subject, df)
}
## ExtractOnePart select among the 561 variables those with a variable name containing the regexp pattern
## the labels of the variables are defined in features (1st column feature index, 2nd column feature label)
## common contains the data from test and train
ExtractOnePart <- function(features, pattern, common) {
  # retrieve the indices fullfilling the pattern
  rows <- grep(pattern, features[,2])
  # subset these variables
  # caveat: the three first columns are dirname, activity, and subject, hence the offset 3.
  df <- common[,features[rows,1] + 3]
  # give the 
  names(df) <- features[rows,2]
  df
}
## MergeTrainTest read the data in the train and test directory
## actlabel is the data.frame with the activity labels
MergeTrainTest <- function(actlabel) {
  test <- ReadOnePart("test", actlabel)
  train <- ReadOnePart("train", actlabel)
  rbind(test, train)
}
## GetFactor retrieves the pos-th component of an interaction with sep="."
GetFactor <- function(inter, pos) {
  unlist(strsplit(inter, ".", fixed=T))[pos]
}
## Main procedure
## datadir is the directory containing the unzipped data
## tidyfile is the tidy data set of question 5 as a csv file with header
run_analysis <- function(datadir = ".", tidyfile = "final.csv") {
  saveddir <- getwd()   # save the current directory
  # switch to the data directory
  setwd(datadir)
  # check wether the data needed are there
  stopifnot(SanityCheck() == 0)

  # read the activity labels
  actlabel <- read.table("activity_labels.txt")
  print("1. Merging the training and the test sets to create one data set.")
  common <- MergeTrainTest(actlabel)
  print("Done.")
  print("2. Extracting only the measurements on the mean and standard deviation for each measurement.")
  # read the feature labels
  features <- read.table("features.txt")
  # read the variables containing mean() in their names
  m <- ExtractOnePart(features, "mean\\(\\)", common)
  # read the variables containing std() in their names
  s <- ExtractOnePart(features, "std\\(\\)", common)
  # concatenate columnwise the two data.frames
  Extract <- cbind(m,s)
  print("Done.")
  print("3. Using descriptive activity names to name the activities in the data set")
  print("solution: use the labels in activities_label.txt")
  print("Done along with the first step.")
  print("4. Appropriately labeling the data set with descriptive activity names.")
  print("solution: define the activities as labels of a factor")
  print("labels for activities in the data set are:")
  print(unique(common[,2]))
  print("Done.") 
  print("5. Creating a second, independent tidy data set with the average of each variable for each activity and each subject.")
  # retrieve the grouping columns as a data.frame of factors
  Groups <- common[,c(2,3)]
  # split the Extract data.frame into a list of chunks, 
  # each list item corresponds to a factor combinaison
  sp <- split(Extract, Groups)
  # compute the means for each factor combinaison columnwise.
  tmp <- sapply(sp, function(x) colMeans(x, na.rm = T))
  # reatrieve the labels of the factor combinaison
  fac <- dimnames(tmp)[2][[1]]
  # Extract the Activity component of the factor combinaison (interaction)
  Activities <- sapply(fac, GetFactor, 1)
  # Extract the Subject component of the factor combinaison
  Subjects <- sapply(fac, GetFactor, 2)
  # Add the activities and the Subjects as the first two column of the tidy data.frame
  # we want Activities Subjects and the mean/std as rows and not as columns: hence the transpose t
  Averages <- as.data.frame(t(rbind(Activities, Subjects, tmp)))
  # output the data.frame as csv file with header into the file named tidyfile
  write.csv(Averages, tidyfile, row.names = FALSE)
  print(sprintf("*** The result is written in %s.", tidyfile))
  print("Done.") 
  setwd(saveddir)
}
run_analysis()
