#' Split dataset into training and test sets
#'
#' Splits the dataset with [`Scikit-learn`](https://scikit-learn.org/stable/index.html)
#' and returns the train/test data and their row/position indices.
#'
#' @param filename A data frame with the data (class and text columns),
#'     otherwise the dataset name (CSV), including full path to the data folder
#'     (if not in the project's working directory), and the data type suffix
#'     (".csv").
#' @param target A string with the name of the response variable.
#' @param predictor A string with the name of the predictor variable.
#' @param test_size Numeric. Proportion of data that will form the test dataset.
#' @param reduce_criticality Logical. For internal use by Nottinghamshire
#'     Healthcare NHS Foundation Trust or other trusts that hold data on
#'     criticality. If `TRUE`, then all records with a criticality of "-5"
#'     (respectively, "5") are assigned a criticality of "-4" (respectively, "4").
#'     This is to avoid situations where the pipeline breaks due to a lack of
#'     sufficient data for "-5" and/or "5". Defaults to `FALSE`.
#' @param theme A string. For internal use by Nottinghamshire Healthcare NHS
#'     Foundation Trust or other trusts that use theme labels ("Access",
#'     "Environment/ facilities" etc.). The column name of the theme variable.
#'     Defaults to `NULL`. If supplied, the theme variable will be used as a
#'     predictor (along with the text predictor) in the model that is fitted
#'     with criticality as the response variable. The rationale is two-fold.
#'     First, to help the model improve predictions on criticality when the
#'     theme labels are readily available. Second, to force the criticality for
#'     "Couldn't be improved" to always be "3" in the training and test data, as
#'     well as in the predictions. This is the only criticality value that
#'     "Couldn't be improved" can take, so by forcing it to always be "3", we
#'     are improving model performance, but are also correcting possible
#'     erroneous assignments of values other than "3" that are attributed to
#'     human error.
#'
#' @return A list of length 6: `x_train` (data frame), `x_test` (data frame),
#'     `y_train` (array), `y_test` (array), `index_training_data`
#'     (integer vector), and `index_test_data` (integer vector). The row names
#'     (names) of `x_train` and `x_test` (`y_train` and `y_test`) are
#'     `index_training_data` and `index_test_data` respectively.
#' @export
#'
#' @references
#' Pedregosa F., Varoquaux G., Gramfort A., Michel V., Thirion B., Grisel O.,
#' Blondel M., Prettenhofer P., Weiss R., Dubourg V., Vanderplas J., Passos A.,
#' Cournapeau D., Brucher M., Perrot M. & Duchesnay E. (2011),
#' [Scikit-learn: Machine Learning in Python](https://jmlr.csail.mit.edu/papers/v12/pedregosa11a.html).
#' _Journal of Machine Learning Research_ 12:2825--2830

#'
#' @examples
#' data_splits <- pxtextmineR::factory_data_load_and_split_r(
#'   filename = pxtextmineR::text_data,
#'   target = "label",
#'   predictor = "feedback",
#'   test_size = 0.33)
#'
#' # Let's take a look at the returned list
#' str(data_splits)
#'
#' # Each record in the split data is tagged with the row index of the original dataset
#' head(rownames(data_splits$x_train))
#' head(names(data_splits$y_train))
#'
#' # Note that, in Python, indices start from 0 and go up to number_of_records - 1
#' all_indices <- data_splits$y_train %>%
#'   names() %>%
#'   c(names(data_splits$y_test)) %>%
#'   as.numeric() %>%
#'   sort()
#' head(all_indices) # Starts from zero
#' tail(all_indices) # Ends in nrow(text_data) - 1
#' length(all_indices) == nrow(text_data)

factory_data_load_and_split_r <- function(filename, target, predictor,
                                          test_size = 0.33,
                                          reduce_criticality = FALSE,
                                          theme = NULL)
{

  # data_load_and_split <- reticulate::py_run_string(
  #   "from pxtextmining.factories.factory_data_load_and_split import factory_data_load_and_split"
  # )$factory_data_load_and_split

  data_load_and_split <- on_load_data_load_and_split$factory_data_load_and_split

  re <- data_load_and_split(filename, target, predictor, test_size,
                            reduce_criticality, theme)

  names(re) <- c("x_train", "x_test", "y_train", "y_test",
                 "index_training_data", "index_test_data")

  # The index values for the training and test sets are returned as a Python
  # Int64Index object, which is probably useless to R users. Convert to array,
  # then to vector.
  re$index_training_data <- as.integer(re$index_training_data$values)
  re$index_test_data <- as.integer(re$index_test_data$values)

  # Assign the row indices of the splits to the y_train/test names.
  names(re$y_train) <- re$index_training_data
  names(re$y_test) <- re$index_test_data

  return(re)
}
