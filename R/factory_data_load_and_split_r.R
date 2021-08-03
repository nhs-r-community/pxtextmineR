#' Split dataset into training and test sets
#'
#' Splits the dataset with `Scikit-learn` and returns the train/test data and
#' their row/position indices.
#'
#' @param filename A string with the dataset name (CSV), including full path to
#'     the data folder (if not in the project's working directory), and the data
#'     type suffix (".csv").
#' @param target A string with the name of the response variable.
#' @param predictor A string with the name of the predictor variable.
#' @param test_size Numeric. Proportion of data that will form the test dataset.
#' @param reduce_criticality  Logical. For internal use by Nottinghamshire
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
#' @param python_setup A `logical` whether to set up the `Python` version,
#'     virtual environment etc. that can be controlled with arguments
#'     `sys_setenv`, `which_python`, `which_venv` and `venv_name`. These
#'     arguments will be ignored when `python_setup` is `FALSE`. The purpose of
#'     `python_setup` is that users may wish to control the `Python` parameters
#'     outside the actual function, for the session in general.
#' @param sys_setenv A string in the form "path_to_python/python.exe",
#'     indicating which Python to use (e.g. from a virtual environment).
#' @param which_python Same as `sys_setenv`.
#' @param which_venv A string that can be "conda", "miniconda" or "python".
#' @param venv_name String. The name of the virtual environment.
#' @param text_col_name A string with the column name of the text variable.
#'
#' @return A list of length 6: `x_train` (data frame), `x_test` (data frame),
#'     `y_train` (character vector), `y_test` (character vector), `index_train`
#'     (integer vector), and `index_test` (integer vector). The row names
#'     (names) of `x_train` and `x_test` (`y_train` and `y_test`) are
#'     `index_train` and `index_test` respectively.
#' @export
#'
#' @examples

factory_data_load_and_split_r <- function(filename, target, predictor,
                                          test_size = 0.33,
                                          reduce_criticality = FALSE,
                                          theme = NULL,
                                          python_setup = FALSE,
                                          sys_setenv = NULL,
                                          which_python = NULL,
                                          which_venv = NULL,
                                          venv_name = NULL)
{
  if (python_setup) {
    experienceAnalysis::prep_python(sys_setenv, which_python, which_venv,
                                    venv_name)
  }

  data_load_and_split <- reticulate::py_run_string(
    "from pxtextmining.factories.factory_data_load_and_split import factory_data_load_and_split"
  )$factory_data_load_and_split

  re <- data_load_and_split(filename, target, predictor, test_size,
                            reduce_criticality, theme)

  names(re) <- c("x_train", "x_test", "y_train", "y_test",
                 "index_train", "index_test")

  # The target datasets y_train/test are arrays, which is a little weird.
  # Convert to vector.
  re$y_train <- as.vector(re$y_train)
  re$y_test <- as.vector(re$y_test)

  # The index values for the training and test sets are returned as a Python
  # Int64Index object, which is probably useless to R users. Convert to array,
  # then to vector.
  re$index_train <- as.integer(re$index_train$values)
  re$index_test <- as.integer(re$index_test$values)

  # Assign the row indices of the splits to the y_train/test names.
  names(re$y_train) <- re$index_train
  names(re$y_test) <- re$index_test

  return(re)
}
