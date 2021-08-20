#' Predict unlabelled text using a fitted `Scikit-learn` (Python) pipeline
#'
#' @param dataset A data frame with the text data to predict classes for.
#' @param predictor A string with the column name of the text variable.
#' @param pipe_path A string in the form "path_to_fitted_pipeline/pipeline.sav",
#'     where "pipeline" is the name of the SAV file with the fitted
#'     `Scikit-learn` pipeline.
#' @param preds_column A string with the user-specified name of the column that
#'     will have the predictions. If `NULL` (default), then the name will be
#'     `paste0(text_col_name, "_preds")`.
#' @param column_names A vector of strings with the names of the columns of the
#'     supplied data frame (incl. `text_col_name`) to be added to the returned
#'     data frame. If "preds_only", then the only column in the returned data
#'     frame will be `preds_column`. Defaults to "all_cols".
#' @param theme
#'
#' @return
#' @export
#'
#' @examples

factory_predict_unlabelled_text_r <- function(dataset, predictor, pipe_path,
                                         preds_column = NULL,
                                         column_names = "all_cols",
                                         theme = NULL) {

  make_predictions <- on_load_predict_text$factory_predict_unlabelled_text

  re <- make_predictions(
    dataset, predictor, pipe_path, preds_column, column_names, theme)

  return(re)
}
