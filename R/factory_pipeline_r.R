#' Prepare and fit a text classification pipeline
#'
#' Prepare and fit a text classification pipeline with
#' [`Scikit-learn`](https://scikit-learn.org/stable/index.html).
#'
#' @param ordinal Whether to fit an ordinal classification model. The ordinal
#'     model is the implementation of [Frank and Hall (2001)](https://www.cs.waikato.ac.nz/~eibe/pubs/ordinal_tech_report.pdf)
#'     that can use any standard classification model that calculates
#'     probabilities.
#' @param x A data frame with the text feature.
#' @param y A vector with the response variable.
#' @param tknz Tokenizer to use ("spacy" or "wordnet").
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
#' @param theme For internal use by Nottinghamshire Healthcare NHS Foundation
#'     Trust or other trusts that use theme labels ("Access",
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
#' @details
#' The pipeline's parameter grid switches between two approaches to text
#' classification: Bag-of-Words and Embeddings. For the former, both TF-IDF and
#' raw counts are tried out.
#'
#' The pipeline does the following:
#'
#' \itemize{
#'     \item{Feature engineering:
#'         \itemize{
#'             \item{Converts text into TF-IDFs or [`GloVe`](https://nlp.stanford.edu/projects/glove/)
#'                 word vectors with [`spaCy`](https://spacy.io/).}
#'             \item{Creates a new feature that is the length of the text in
#'                  each record.}
#'             \item{Performs sentiment analysis on the text feature and creates
#'                 new features that are all scores/indicators produced by
#'                 [`TextBlob`](https://textblob.readthedocs.io/en/dev/)
#'                 and [`vaderSentiment`](https://pypi.org/project/vaderSentiment/).}
#'             \item{Applies [`sklearn.preprocessing.KBinsDiscretizer`](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.KBinsDiscretizer.html)
#'                 to the text length and sentiment indicator features, and
#'                 [`sklearn.preprocessing.StandardScaler`](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.StandardScaler.html)
#'                 to the embeddings (word vectors).}
#'         }
#'     }
#'     \item{Up-sampling of rare classes: uses [`imblearn.over_sampling.RandomOverSampler`](https://imbalanced-learn.org/stable/references/generated/imblearn.over_sampling.RandomOverSampler.html#imblearn.over_sampling.RandomOverSampler)
#'         to up-sample rare classes. Currently the threshold to consider a
#'         class as rare and the up-balancing values are fixed and cannot be
#'         user-defined.}
#'     \item{Tokenization and lemmatization of the text feature: uses `spaCy`
#'         (default) or [`NLTK`](https://www.nltk.org/). It also strips
#'         punctuation, excess spaces, and metacharacters "r" and "n" from the
#'         text. It converts emojis into `"__text__"` (where "text" is the emoji
#'         name), and NA/NULL values into `"__notext__"` (the pipeline does get
#'         rid of records with no text, but this conversion at least deals with
#'         any escaping ones).}
#'     \item{Feature selection: Uses [`sklearn.feature_selection.SelectPercentile`](https://scikit-learn.org/stable/modules/generated/sklearn.feature_selection.SelectPercentile.html)
#'         with [`sklearn.feature_selection.chi2`](https://scikit-learn.org/stable/modules/generated/sklearn.feature_selection.chi2.html#sklearn.feature_selection.chi2)
#'         for TF-IDFs or [`sklearn.feature_selection.f_classif`](https://scikit-learn.org/stable/modules/generated/sklearn.feature_selection.f_classif.html#sklearn-feature-selection-f-classif)
#'         for embeddings.}
#'     \item{Fitting and benchmarking of user-supplied `Scikit-learn`
#'     [estimators](https://scikit-learn.org/stable/modules/classes.html).}
#' }
#'
#' The numeric values in the grid are currently lists/tuples (Python objects) of
#' values that are defined either empirically or are based on the published
#' literature (e.g. for Random Forest, see [`Probst et al. 2019`](https://arxiv.org/abs/1802.09596)).
#' Values may be replaced by appropriate distributions in a future release.
#'
#' @return A fitted `Scikit-learn` pipeline containing a number of objects that
#'     can be accessed with the `$` sign (see examples). For a partial list see
#'     "Atributes" in [`sklearn.model_selection.RandomizedSearchCV`](https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.RandomizedSearchCV.html).
#'     Do not be surprised if more objects are in the pipeline than those in the
#'     aforementioned "Attributes" list. Python objects can contain a wide array
#'     of objects, from numeric results (e.g. the pipeline's accuracy),
#'     to _methods_ (i.e. functions in the R lingo) and _classes_. In Python,
#'     these are normally accessed with `object.<whatever>`, but in R the
#'     command is `object$<whatever>`. For instance, one can access method
#'     `predict()` to make predictions on unseen data. See examples.
#'
#' @export
#'
#' @note The pipeline uses the tokenizers of `Python` library `pxtextmining`.
#'     Any warnings from `Scikit-learn` like `UserWarning: The parameter
#'     'token_pattern' will not be used since 'tokenizer' is not None'` can
#'     therefore be safely ignored.\cr\cr
#'     Also, any warnings about over-sampling can also be safely ignored. These
#'     warnings are simply a result of an internal check in the over-sampler of
#'     [`imblearn`](https://imbalanced-learn.org/stable/install.html).
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
#' Probst P., Bischl B. & Boulesteix A-L (2018). Tunability: Importance of
#' Hyperparameters of Machine Learning Algorithms.
#' \url{https://arxiv.org/abs/1802.09596}
#'
#' @examples
#' # One can set the python.exe and virtual environment directly in the pxtextmineR
#' # functions or globally, with experienceAnalysis
#' # (https://github.com/CDU-data-science-team/experienceAnalysis).
#'
#' experienceAnalysis::prep_python(
#'   sys_setenv = "C:/Users/andreas.soteriades/Anaconda3/envs/pxtextmining_venv/python.exe",
#'   which_python = "C:/Users/andreas.soteriades/Anaconda3/envs/pxtextmining_venv/python.exe",
#'   which_venv = "conda",
#'   venv_name = "pxtextmining_venv"
#' )
#'
#' # Prepare training and test sets
#' data_splits <- pxtextmineR::factory_data_load_and_split_r(
#'   filename = text_data,
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
#'   cv = 2, n_iter = 1, n_jobs = 1, verbose = 3,
#'   learners = "SGDClassifier"
#' )
#'
#' # Mean cross-validated score of the best_estimator
#' pipe$best_score_
#'
#' # Best parameters during tuning
#' pipe$best_params_
#'
#' # Make predictions
#' preds <- pipe$predict(data_splits$x_test)
#' head(preds)
#'
#' # Performance on test set #
#' # Can be done using the pipe's score() method
#' pipe$score(data_splits$x_test, data_splits$y_test)
#'
#' # Or using dplyr
#' data_splits$y_test %>%
#'   data.frame() %>%
#'   dplyr::rename(true = '.') %>%
#'   dplyr::mutate(
#'     pred = preds,
#'     check = true == preds,
#'     check = sum(check) / nrow(.)
#'   ) %>%
#'   dplyr::pull(check) %>%
#'   unique()

factory_pipeline_r <- function(x, y, tknz = "spacy", ordinal = FALSE,
                               metric = "class_balance_accuracy_score",
                               cv = 5, n_iter = 2, n_jobs = 1, verbose = 3,
                               learners = c(
                                 "SGDClassifier",
                                 "RidgeClassifier",
                                 "Perceptron",
                                 "PassiveAggressiveClassifier",
                                 "BernoulliNB",
                                 "ComplementNB",
                                 "MultinomialNB",
                                 # "KNeighborsClassifier",
                                 # "NearestCentroid",
                                 "RandomForestClassifier"
                               ),
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

  pipeline <- reticulate::py_run_string(
    "from pxtextmining.factories.factory_pipeline import factory_pipeline"
  )$factory_pipeline

  # Scikit-learn expects integer values for cv, n_iter, n_jobs and verbose. In R
  # seemingly integer numbers are of class "numeric" instead. Explicitly convert
  # to integer.
  cv <- as.integer(cv)
  n_iter <- as.integer(n_iter)
  n_jobs <- as.integer(n_jobs)
  verbose <- as.integer(verbose)

  re <- pipeline(x, y, tknz, ordinal, metric, cv, n_iter, n_jobs,
                 verbose, learners, theme)

  return(re)
}
