CodeBook.md
========================================================

For the assignment, we made the assumption that the useful data is spread over the following files:
* **activity_labels.txt**: contains the levels and the labels for the activity (y variable). We do not assume that the list sorted by increasing value of the levels.
* **features.txt**: contains the labels for the X variables. The first row is the column index of the variable, the second one is the name of the X variable. We do not assume that the list is sorted by increasing index of the variables
* in the two directories **train** and **test** we use the following files:
  * **X_test.txt and X_train.txt** that contain the X observations. The table has 561 columns described by features.txt
  * **y_test.txt and y_train.txt**: the y variable: the activities corresponding to the X observations. The meaning of the levels are defined by activity_label.txt. 
  * **subject_test.txt and subject_train.txt**: Another factor variable ranging from 1 to 30. Each level identifies a distinct subject.

## The merged data.frame

The data.frame *common* defined in the environment of the function *run_analysis* is the result of a two step procedure:
* columnwise join of the following variables into two distinct data.frames produced by the helper funcion *ReadOnePart*:
  * **dirname**: a factor with two modalities: test or train. This variable is not required by the assignment, but it seems reasonable to carry over the origin of each observation.
  * **y**: the activity defined as a factor. The activities are the y variable read rsp. from either y_test.txt or y_train.txt according to the dirname factor. Since the assignment  demands that meaningful labels were given, we just use the labels in activity_label.txt by using the factor function with the *labels* parameter. Whenever a new release of the data set is issued, there will be no need to manually update the list of labels. Simply rerun the script.
  * **all the variables** of eiter X_test.txt or X_train.txt according to the dirname factor. The column names for these 561 variables are read from features.txt. We do not make the assumption that this list is sorted by increasing index of the variables.
* rowwise join of the two previous data.frames

# The extraction of mean and std variables

The features data.frame (origin: features.txt) is processed to extract the variable names with the following patterns:
* mean()
* std()
internally the grep function is used hence more sophisticated pattern could be used if needed.

For each pattern we collect the indices of the selected variable names (the first column of the *features* data.frame) into a vector of column indices in order to define two data.frames *m* and *s* by subsetting columnwise the data.frame *common*. The names of the variables are attached to the the columns of the data.frames *m* and *s*.
The data.frames *m* and *s* are join columnwise into the data.frame *Extract*.

# The computation of the mean per activity and subject
The interaction factors activity and subject correspond to the 2nd and 3rd columns of the data.frame *common*. These two columns are extracted into the data.frame *Groups*

The componentwise means on the *split(Extract, Groups)* are computed with colMeans using the sapply function. The resulting maxtrix is called tmp.

# Preparation of the final data set

The assignment requirements are not clear on this topic, but without the factors of the data.frame *Groups* as atomic information (in their own column), the use of the final data.frame would become cumbersome.
Therefore these two columns are computed by processing the the names of the columns of the matrix *tmp* and added as the two first columns of the final data.frame.

We define the final tidy data.frame as made up of the following columns:
* **Activities**; the first component of the interaction variable
* **Subjects**: the second component of the interaction variable
* the remaining columns are the bucketwise means from the columns of data.frame *Extract* (same order, same name)

This final data.frame is written to disk as a csv file with headers.
