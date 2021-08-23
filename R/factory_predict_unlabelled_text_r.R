#' Predict unlabelled text using a fitted `Scikit-learn` (Python) pipeline
#'
#' @param dataset Data frame. The text data to predict classes for.
#' @param predictor String. The column name of the text variable.
#' @param pipe_path_or_object String or
#'     `sklearn.model_selection._search.RandomizedSearchCV` (e.g. from
#'     \code{\link{factory_pipeline_r}}). If a string, it should be in the form
#'     "path_to_fitted_pipeline/pipeline.sav", where "pipeline" is the name of
#'     the SAV file with the fitted `Scikit-learn` pipeline.
#' @param preds_column A string with the user-specified name of the column that
#'     will have the predictions. If `NULL` (default), then the name will be
#'     `paste0(text_col_name, "_preds")`.
#' @param column_names A vector of strings with the names of the columns of the
#'     supplied data frame (incl. `text_col_name`) to be added to the returned
#'     data frame. If "preds_only", then the only column in the returned data
#'     frame will be `preds_column`. Defaults to "all_cols".
#' @param theme String. For internal use by Nottinghamshire Healthcare NHS
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
#' @return Data frame. The predictions column with or without any other columns
#'     passed by the user (see `column_names`).
#' @export
#'
#' @examples
#' # Prepare training and test sets
#' data_splits <- pxtextmineR::factory_data_load_and_split_r(
#'   filename = pxtextmineR::text_data,
#'   target = "label",
#'   predictor = "feedback",
#'   test_size = 0.90)
#'
#' # Fit the pipeline
#' pipe <- pxtextmineR::factory_pipeline_r(
#'   x = data_splits$x_train,
#'   y = data_splits$y_train,
#'   tknz = "spacy",
#'   ordinal = FALSE,
#'   metric = "accuracy_score",
#'   cv = 2, n_iter = 1, n_jobs = 1, verbose = 3,
#'   learners = "SGDClassifier"
#' )
#'
#' # Make predictions #
#' # Return data frame with predictions column and all original columns from
#' # the supplied data frame
#' preds_all_cols <- pxtextmineR::factory_predict_unlabelled_text_r(
#'   dataset = pxtextmineR::text_data,
#'   predictor = "feedback",
#'   pipe_path_or_object = pipe,
#'   column_names = "all_cols")
#'
#' str(preds_all_cols)
#'
#' # Return data frame with predictions column only
#' preds_preds_only <- pxtextmineR::factory_predict_unlabelled_text_r(
#'   dataset = pxtextmineR::text_data,
#'   predictor = "feedback",
#'   pipe_path_or_object = pipe,
#'   column_names = "preds_only")
#'
#' head(preds_preds_only)
#'
#' # Return data frame with predictions column and columns label and feedback from
#' # the supplied data frame
#' preds_label_text <- pxtextmineR::factory_predict_unlabelled_text_r(
#'   dataset = pxtextmineR::text_data,
#'   predictor = "feedback",
#'   pipe_path_or_object = pipe,
#'   column_names = c("label", "feedback"))
#'
#' str(preds_label_text)
#'
#' # Return data frame with the predictions column name supplied by the user
#' preds_custom_preds_name <- pxtextmineR::factory_predict_unlabelled_text_r(
#'   dataset = pxtextmineR::text_data,
#'   predictor = "feedback",
#'   pipe_path_or_object = pipe,
#'   column_names = "preds_only",
#'   preds_column = "predictions")
#'
#' head(preds_custom_preds_name)

factory_predict_unlabelled_text_r <- function(dataset, predictor,
                                              pipe_path_or_object,
                                              preds_column = NULL,
                                              column_names = "all_cols",
                                              theme = NULL) {

  make_predictions <- on_load_predict_text$factory_predict_unlabelled_text

  # The behaviour of {reticulate} is not clear. If the user passes "all_cols" or
  # "preds_only" directly into column_names in the Python function, without the
  # if/else below, then the Python function will throw this error:
  # TypeError: 'DataFrame' objects are mutable, thus they cannot be hashed
  # This is weird- in theory, we are passing an R string that {reticulate} should
  # convert into a Python string, expecting that the Python function would
  # handle in an internal if/else statement.
  if (all(column_names == "all_cols")) {
    column_names <- names(dataset)
  } else if (all(column_names == "preds_only")) {
    column_names <- NULL
  }

  re <- make_predictions(
    dataset, predictor, pipe_path_or_object, preds_column, column_names, theme)

  return(re)
}
