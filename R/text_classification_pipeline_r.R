#' Fit and evaluate the pipeline
#'
#' Split the data, build and fit the pipeline, produce performance metrics.
#'
#' @param filename A data frame with the data (class and text columns),
#'     otherwise the dataset name (CSV), including full path to the data folder
#'     (if not in the project's working directory), and the data type suffix
#'     (".csv").
#' @param target A string with the name of the response variable.
#' @param predictor A string with the name of the predictor variable.
#' @param test_size Numeric. Proportion of data that will form the test dataset.
#' @param tknz Tokenizer to use ("spacy" or "wordnet").
#' @param ordinal Whether to fit an ordinal classification model. The ordinal
#'     model is the implementation of [Frank and Hall (2001)](https://www.cs.waikato.ac.nz/~eibe/pubs/ordinal_tech_report.pdf)
#'     that can use any standard classification model that calculates
#'     probabilities.
#' @param metric A string. Scorer to use during pipeline tuning
#'     ("accuracy_score", "balanced_accuracy_score", "matthews_corrcoef",
#'     "class_balance_accuracy_score").
#' @param cv Number of cross-validation folds.
#' @param n_iter Number of parameter settings that are sampled (see
#'     [`sklearn.model_selection.RandomizedSearchCV`](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.RandomizedSearchCV.html)).
#' @param n_jobs Number of jobs to run in parallel (see `sklearn.model_selection.RandomizedSearchCV`).
#'     __NOTE:__ If your machine does not have the number of cores specified in
#'     `n_jobs`, then an error will be returned.
#' @param verbose Controls the verbosity (see `sklearn.model_selection.RandomizedSearchCV`).
#' @param learners A vector of `Scikit-learn` names of the learners to tune. Must
#'     be one or more of "SGDClassifier", "RidgeClassifier", "Perceptron",
#'     "PassiveAggressiveClassifier", "BernoulliNB", "ComplementNB",
#'    "MultinomialNB", "KNeighborsClassifier", "NearestCentroid",
#'    "RandomForestClassifier". When a single model is used, it can be passed as
#'    a string.
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
#' @details This function brings together the three functions that run chunks of
#'     the process independently, namely splitting data into training and test
#'     sets (\code{\link{factory_data_load_and_split_r}}), building and fitting
#'     the pipeline (\code{\link{factory_pipeline_r}}), and assessing pipeline
#'     performance (\code{\link{factory_model_performance_r}}).
#'
#' @return A list of length 7:
#'     \itemize{
#'         \item{A fitted `Scikit-learn` pipeline containing a number of objects
#'             that can be accessed with the `$` sign (see examples). For a
#'             partial list see "Atributes" in
#'             [`sklearn.model_selection.RandomizedSearchCV`](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.RandomizedSearchCV.html).
#'             Do not be surprised if more objects are in the pipeline than
#'             those in the aforementioned "Attributes" list. Python objects can
#'             contain several objects, from numeric results (e.g. the
#'             pipeline's accuracy), to _methods_ (i.e. functions in the R
#'             lingo) and _classes_. In Python, these are normally accessed with
#'             `object.<whatever>`, but in R the command is `object$<whatever>`.
#'             For instance, one can access method `predict()` to make  to make
#'             predictions on unseen data. See Examples.}
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
#'         \item{`index_training_data` The row names/indices of the training
#'             data.
#'         }
#'         \item{`index_test_data` The row names/indices of the test data.}
#'     }
#'
#' @references
#' Frank E. & Hall M. (2001). A Simple Approach to Ordinal Classification.
#' _Machine Learning: ECML 2001_ 145--156.
#'
#' Pedregosa F., Varoquaux G., Gramfort A., Michel V., Thirion B., Grisel O.,
#' Blondel M., Prettenhofer P., Weiss R., Dubourg V., Vanderplas J., Passos A.,
#' Cournapeau D., Brucher M., Perrot M. & Duchesnay E. (2011),
#' [Scikit-learn: Machine Learning in Python](https://jmlr.csail.mit.edu/papers/v12/pedregosa11a.html).
#' _Journal of Machine Learning Research_ 12:2825–-2830.
#'
#' @export
#'
#' @examples

text_classification_pipeline_r <-
  function(filename,
           target, predictor, test_size = 0.33,
           ordinal = FALSE,
           tknz = "spacy",
           metric = "class_balance_accuracy_score",
           cv = 2, n_iter = 1, n_jobs = 1, verbose = 3,
           learners = c("SGDClassifier"),
           reduce_criticality = FALSE,
           theme = NULL
  ) {

    # Split the data #
    splits <- pxtextmineR::factory_data_load_and_split_r(filename, target,
      predictor, test_size, reduce_criticality, theme)

    # Fit the pipeline #
    # Scikit-learn expects integer values for cv, n_iter, n_jobs and verbose. In
    # R seemingly integer numbers are of class "numeric" instead. Explicitly
    # convert into integer.
    cv <- as.integer(cv)
    n_iter <- as.integer(n_iter)
    n_jobs <- as.integer(n_jobs)
    verbose <- as.integer(verbose)

    pipe <- pxtextmineR::factory_pipeline_r(
      x = splits$x_train,
      y = splits$y_train,
      tknz, ordinal, metric, cv, n_iter, n_jobs, verbose, learners, theme
    )

    # Model performance
    performance <- pxtextmineR::factory_model_performance_r(
      pipe,
      x_train = splits$x_train,
      y_train = splits$y_train,
      x_test = splits$x_test,
      y_test = splits$y_test,
      metric
    )

    # Gather all results #
    re <- list(
      pipe = pipe,
      tuning_results = performance$tuning_results,
      pred = performance$pred,
      accuracy_per_class = performance$accuracy_per_class,
      p_compare_models_bar = performance$p_compare_models_bar,
      index_training_data = splits$index_train,
      index_test_data = splits$index_test
    )

    return(re)
}



