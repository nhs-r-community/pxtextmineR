#' Class Balance Accuracy Score
#'
#' Assess classifier performance with Mosley's (2013) Class Balance Accuracy
#' score.
#'
#' @param y_true Vector. The true classes.
#' @param y_pred Vector. The predicted classes.
#'
#' @details The Class Balance Accuracy Score is a type of balanced accuracy
#'     score to assess classifier performance on data with imbalanced classes in
#'     multi-class supervised learning.\cr\cr
#'     From Mosley (2013, p. 41--42):
#'     "From its construction, CBA utilizes three core elements from each class
#'     within the contingency table: the total number of correctly classified
#'     cases, the total number of cases predicted into that class, and the total
#'     number observed in the data. Intuitively, for each class the off-diagonal
#'     row and column elements are reduced into a single sum. These singular sums
#'     form the basis for the denominator of the per class accuracy contributions.
#'     At the bottom of each per class ratio, the maximum of the row or column
#'     sum is chosen resulting in either the Recall or Precision to be the
#'     estimate of class accuracy. As a consequence, selecting the larger of the
#'     two as the denominator provides the most conservative estimate of accuracy
#'     that can be achieved. For each class, the per class Recall or Precision
#'     are aggregated and treated as the numerator for the final ratio
#'     calculation. By using the total number of classes in the dataset as the
#'     divisor in the calculation we guarantee equal weight contributions for
#'     all classes. In the end, Class Balance Accuracy acts as a measure that
#'     independently accounts for the ability of the model to precisely recall
#'     observations from each group within the target variable."
#'
#' @return Numeric. The Class Balance Accuracy score.
#' @export
#'
#' @references
#' Mosley L. (2013). A balanced approach to the multi-class imbalance problem.
#' _Graduate Theses and Dissertations_. 13537.
#' https://lib.dr.iastate.edu/etd/13537.
#'
#' @examples
#' x <- pxtextmineR::text_data %>%
#'   dplyr::mutate(label_pred = sample(label, size = nrow(.))) # Mock predictions column
#'
#' pxtextmineR::class_balance_accuracy_score_r(x$label, x$label_pred)

class_balance_accuracy_score_r <- function(y_true, y_pred) {

  cba <- on_load_cba$class_balance_accuracy_score

  re <- cba(y_true, y_pred)

  return(re)
}
