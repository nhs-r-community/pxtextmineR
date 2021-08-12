#' Evaluate the performance of a fitted pipeline
#'
#' Performance metrics on the test set.
#'
#' @param x_train A data frame. Training data (predictor).
#' @param y_train A vector. Training data (response).
#' @param x_test A data frame. Test data (predictor).
#' @param y_test A vector. Test data (response).
#' @param metric A string. Scorer that was used in pipeline tuning
#'     ("accuracy_score", "balanced_accuracy_score", "matthews_corrcoef",
#'     "class_balance_accuracy_score")
#'
#' @return A list of length 5:
#'     \itemize{
#'         \item{`pipe` The fitted `Scikit-learn`/`imblearn` pipeline.}
#'         \item{`tuning_results` A data frame with all (hyper)parameter values
#'             and models tried during fitting.
#'         }
#'         \item{`pred` A vector with the predictions on the test
#'             set.
#'         }
#'         \item{`accuracy_per_class` A data frame with accuracies per class.}
#'         \item{`p_compare_models_bar` A bar plot comparing the mean scores (of
#'             the user-supplied `metric` parameter) from the cross-validation
#'             on the training set, for the best (hyper)parameter values for
#'             each learner.
#'         }
#'     }
#'
#' @export
#'
#' @note Returned object `tuning_results` lists all (hyper)parameter values
#'     tried during pipeline fitting, along with performance metrics. It is
#'     generated from the `Scikit-learn` output that follows pipeline fitting.
#'     It is derived from attribute [`cv_results_`](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.RandomizedSearchCV.html)
#'     with some modifications. In R, `cv_results_` can be accessed following
#'     fitting of a pipeline with `pxtextmineR::factory_pipeline_r` or by
#'     calling function `pxtextmineR::factory_model_performance_r`. Say that
#'     the fitted pipeline is assigned to an object called `pipe`, and that the
#'     pipeline performance is assigned to an object called `pipe_performance`.
#'     Then, `cv_results_` can be accessed with `pipe$cv_results_` or
#'     `pipe_performance$cv_results_`. \cr\cr
#'     NOTE: After calculating performance metrics on the test set,
#'     `pxtextmineR::factory_model_performance_r` fits the pipeline on the whole
#'     dataset (train + test). Hence, do not be surprised that the pipeline's
#'     `score()` method will now return a dramatically improved score on the
#'     test set- it is just a result of overfitting, because the refitted
#'     pipeline has now "seen" the test dataset. See Examples.
#'
#' @references
#' Pedregosa F., Varoquaux G., Gramfort A., Michel V., Thirion B., Grisel O.,
#' Blondel M., Prettenhofer P., Weiss R., Dubourg V., Vanderplas J., Passos A.,
#' Cournapeau D., Brucher M., Perrot M. & Duchesnay E. (2011),
#' [Scikit-learn: Machine Learning in Python](https://jmlr.csail.mit.edu/papers/v12/pedregosa11a.html).
#' _Journal of Machine Learning Research_ 12:2825–-2830.
#'
#' @examples
#' # Prepare training and test sets
#' data_splits <- pxtextmineR::factory_data_load_and_split_r(
#'   filename = pxtextmineR::text_data,
#'   target = "label",
#'   predictor = "feedback",
#'   test_size = 0.90) # Make a small training set for a faster run in this example
#'
#' # Let's take a look at the returned list
#' str(data_splits)
#'
#' # Fit the pipeline
#' pipe <- pxtextmineR::factory_pipeline_r(
#'   x = data_splits$x_train,
#'   y = data_splits$y_train,
#'   tknz = "spacy",
#'   ordinal = FALSE,
#'   metric = "accuracy_score",
#'   cv = 2, n_iter = 10, n_jobs = 1, verbose = 3,
#'   learners = c("SGDClassifier", "MultinomialNB")
#' )
#'
#' # Assess model performance
#' pipe_performance <- pxtextmineR::factory_model_performance_r(
#'   pipe = pipe,
#'   x_train = data_splits$x_train,
#'   y_train = data_splits$y_train,
#'   x_test = data_splits$x_test,
#'   y_test = data_splits$y_test,
#'   metric = "accuracy_score")
#'
#' names(pipe_performance)
#'
#' # Let's compare pipeline performance for different tunings with a range of metrics
#' pipe_performance$
#'   tuning_results %>%
#'   dplyr::select(learner, dplyr::contains("mean_test"))
#'
#' # A glance at the (hyper)parameters and their tuned values
#' pipe_performance$
#'   tuning_results %>%
#'   dplyr::select(learner, dplyr::contains("param_")) %>%
#'   str()
#'
#' # Accuracy per class
#' pipe_performance$accuracy_per_class
#'
#' # Learner performance barplot
#' pipe_performance$p_compare_models_bar
#'
#' # Predictions on test set
#' preds <- pipe_performance$pred
#' head(preds)
#'
#' ################################################################################
#' # NOTE!!! #
#' ################################################################################
#' # After calculating performance metrics on the test set,
#' # pxtextmineR::factory_model_performance_r fits the pipeline on the whole
#' # dataset (train + test). Hence, do not be surprised that the pipeline's score()
#' # method will now return a dramatically improved score on the test set- it is
#' # just a result of overfitting, because the refitted pipeline has now "seen" the
#' # test dataset.
#' pipe_performance$pipe$score(data_splits$x_test, data_splits$y_test)
#' pipe$score(data_splits$x_test, data_splits$y_test)
#'
#' # We can confirm this score by having the re-fitted pipeline predict x_test
#' # again. The predictions will be better and new accuracy score will be the
#' # inflated one.
#' preds_refitted <- pipe$predict(data_splits$x_test)
#'
#' score_refitted <- data_splits$y_test %>%
#'   data.frame() %>%
#'   dplyr::rename(true = '.') %>%
#'   dplyr::mutate(
#'     pred = preds_refitted,
#'     check = true == preds_refitted,
#'     check = sum(check) / nrow(.)
#'   ) %>%
#'   dplyr::pull(check) %>%
#'   unique()
#'
#'   score_refitted
#'
#' # Compare this to the ACTUAL performance on the test dataset
#' preds_actual <- pipe_performance$pred
#'
#' score_actual <- data_splits$y_test %>%
#'   data.frame() %>%
#'   dplyr::rename(true = '.') %>%
#'   dplyr::mutate(
#'     pred = preds_actual,
#'     check = true == preds_actual,
#'     check = sum(check) / nrow(.)
#'   ) %>%
#'   dplyr::pull(check) %>%
#'   unique()
#'
#'   score_actual
#'
#'   score_refitted - score_actual

factory_model_performance_r <- function(pipe, x_train, y_train, x_test, y_test,
                                      metric)
{

  model_performance <- on_load_model_performance$factory_model_performance

  re <- model_performance(pipe, x_train, y_train, x_test, y_test,
                          metric)

  names(re) <- c("pipe", "tuning_results", "pred", "accuracy_per_class",
                 "p_compare_models_bar")

  ##############################################################################
  # The Python method factory_model_performance() that function
  # factory_model_performance_r() wraps produces a matplotlib plot. Let's better
  # replace this with a ggplot.
  ##############################################################################
  # This is for later use
  y_axis <- metric %>%
    gsub("_", " ", x = .) %>%
    gsub(" score", "", x = .) %>%
    stringr::str_to_title() %>%
    paste0("mean_test_", .)

  re$p_compare_models_bar <- re$tuning_results %>%
    dplyr::select(dplyr::matches("mean_test|learner")) %>% # We only want the learners and their scores.
    dplyr::group_by(learner) %>%
    dplyr::slice(1) %>% # For each learner, the best score according to the specified metric is at the top row.
    dplyr::ungroup() %>%
    dplyr::arrange(
      dplyr::across(
        dplyr::all_of(y_axis), # Arrange learners from best to worst according to the specified metric.
        ~ dplyr::desc(.)
      )
    ) %>%
    tidyr::pivot_longer(cols = tidyselect:::where(is.numeric)) %>%
    dplyr::mutate(
      name = sub("mean_test_", "", name),
      learner = sub("Classifier", "", learner)
    ) %>%
    ggplot2::ggplot(
      ggplot2::aes(
        # Leftmost learner on the bar plot should be the best one according to
        # the specified metric. The long table's learner column has the best
        # learner at the top, and the rest in descending order. Thus,
        # unique(learner) will return unique learners in this sorted order in
        # which they appear on the learners column. This changes the factor
        # levels so that the learners appear on the plot in descending order
        # (left to right) according to the specified metric.
        factor(learner, levels = unique(learner)),
        value,
        fill = name
      )
    ) +
    ggplot2::geom_col(position = "dodge", alpha = 0.6) +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(
        size = 12, angle = 90, hjust = 0.95, vjust = 0.2
      ),
      axis.text.y = ggplot2::element_text(size = 12),
      legend.title = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(size = 12)
    ) +
    ggthemes::scale_fill_colorblind()

  return(re)
}
