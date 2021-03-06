% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/factory_model_performance_r.R
\name{factory_model_performance_r}
\alias{factory_model_performance_r}
\title{Evaluate the performance of a fitted pipeline}
\usage{
factory_model_performance_r(pipe, x_train, y_train, x_test, y_test, metric)
}
\arguments{
\item{x_train}{Data frame. Training data (predictor).}

\item{y_train}{Vector. Training data (response).}

\item{x_test}{Data frame. Test data (predictor).}

\item{y_test}{Vector. Test data (response).}

\item{metric}{String. Scorer that was used in pipeline tuning
("accuracy_score", "balanced_accuracy_score", "matthews_corrcoef",
"class_balance_accuracy_score")}
}
\value{
A list of length 5:
\itemize{
\item{\code{pipe} The fitted \code{Scikit-learn}/\code{imblearn} pipeline.}
\item{\code{tuning_results} Data frame. All (hyper)parameter values
and models tried during fitting.
}
\item{\code{pred} Vector. The predictions on the test
set.
}
\item{\code{accuracy_per_class} Data frame. Accuracies per class.}
\item{\code{p_compare_models_bar} A bar plot comparing the mean scores (of
the user-supplied \code{metric} parameter) from the cross-validation
on the training set, for the best (hyper)parameter values for
each learner.
}
}
}
\description{
Performance metrics on the test set.
}
\note{
Returned object \code{tuning_results} lists all (hyper)parameter values
tried during pipeline fitting, along with performance metrics. It is
generated from the \code{Scikit-learn} output that follows pipeline fitting.
It is derived from attribute \href{https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.RandomizedSearchCV.html}{\code{cv_results_}}
with some modifications. In R, \code{cv_results_} can be accessed following
fitting of a pipeline with \code{pxtextmineR::factory_pipeline_r} or by
calling function \code{pxtextmineR::factory_model_performance_r}. Say that
the fitted pipeline is assigned to an object called \code{pipe}, and that the
pipeline performance is assigned to an object called \code{pipe_performance}.
Then, \code{cv_results_} can be accessed with \code{pipe$cv_results_} or
\code{pipe_performance$cv_results_}. \cr\cr
\strong{NOTE}: After calculating performance metrics on the test set,
\code{pxtextmineR::factory_model_performance_r} fits the pipeline on the
\strong{whole} dataset (train + test). Hence, do not be surprised that the
pipeline's \code{score()} method will now return a dramatically improved score
on the test set- the refitted pipeline has now "seen" the test dataset
(see Examples). The re-fitted pipeline will perform much better on fresh
data than the pipeline fitted on \code{x_train} and \code{y_train} only.
}
\examples{
# Prepare training and test sets
data_splits <- pxtextmineR::factory_data_load_and_split_r(
  filename = pxtextmineR::text_data,
  target = "label",
  predictor = "feedback",
  test_size = 0.90) # Make a small training set for a faster run in this example

# Let's take a look at the returned list
str(data_splits)

# Fit the pipeline
pipe <- pxtextmineR::factory_pipeline_r(
  x = data_splits$x_train,
  y = data_splits$y_train,
  tknz = "spacy",
  ordinal = FALSE,
  metric = "accuracy_score",
  cv = 2, n_iter = 10, n_jobs = 1, verbose = 3,
  learners = c("SGDClassifier", "MultinomialNB")
)
# (SGDClassifier represents both logistic regression and linear SVM. This
# depends on the value of the "loss" hyperparameter, which can be "log" or
# "hinge". This is set internally in factory_pipeline_r).

# Assess model performance
pipe_performance <- pxtextmineR::factory_model_performance_r(
  pipe = pipe,
  x_train = data_splits$x_train,
  y_train = data_splits$y_train,
  x_test = data_splits$x_test,
  y_test = data_splits$y_test,
  metric = "accuracy_score")

names(pipe_performance)

# Let's compare pipeline performance for different tunings with a range of
# metrics averaging the cross-validation metrics for each fold.
pipe_performance$
  tuning_results \%>\%
  dplyr::select(learner, dplyr::contains("mean_test"))

# A glance at the (hyper)parameters and their tuned values
pipe_performance$
  tuning_results \%>\%
  dplyr::select(learner, dplyr::contains("param_")) \%>\%
  str()

# Accuracy per class
pipe_performance$accuracy_per_class

# Learner performance barplot
pipe_performance$p_compare_models_bar
# Remember that we tried three models: Logistic regression (SGDClassifier with
# "log" loss), linear SVM (SGDClassifier with "hinge" loss) and MultinomialNB.
# Do not be surprised if one of these models does not show on the plot.
# There are numerous values for the different (hyper)parameters (recall,
# most of which are set internally) and only `n_iter = 10` iterations in this
# example. As with `factory_pipeline` the choice of which (hyper)parameter
# values to try out is random, one or more classifiers may not be chosen.
# Increasing `n_iter` to a larger number would avoid this, at the expense of
# longer fitting times (but with a possibly more accurate pipeline).

# Predictions on test set
preds <- pipe_performance$pred
head(preds)

################################################################################
# NOTE!!! #
################################################################################
# After calculating performance metrics on the test set,
# pxtextmineR::factory_model_performance_r fits the pipeline on the WHOLE
# dataset (train + test). Hence, do not be surprised that the pipeline's
# score() method will now return a dramatically improved score on the test
# set- the refitted pipeline has now "seen" the test dataset.
pipe_performance$pipe$score(data_splits$x_test, data_splits$y_test)
pipe$score(data_splits$x_test, data_splits$y_test)

# We can confirm this score by having the re-fitted pipeline predict x_test
# again. The predictions will be better and the new accuracy score will be
# the inflated one.
preds_refitted <- pipe$predict(data_splits$x_test)

score_refitted <- data_splits$y_test \%>\%
  data.frame() \%>\%
  dplyr::rename(true = '.') \%>\%
  dplyr::mutate(
    pred = preds_refitted,
    check = true == preds_refitted,
    check = sum(check) / nrow(.)
  ) \%>\%
  dplyr::pull(check) \%>\%
  unique()

score_refitted

# Compare this to the ACTUAL performance on the test dataset
preds_actual <- pipe_performance$pred

score_actual <- data_splits$y_test \%>\%
  data.frame() \%>\%
  dplyr::rename(true = '.') \%>\%
  dplyr::mutate(
    pred = preds_actual,
    check = true == preds_actual,
    check = sum(check) / nrow(.)
  ) \%>\%
  dplyr::pull(check) \%>\%
  unique()

score_actual

score_refitted - score_actual
}
\references{
Pedregosa F., Varoquaux G., Gramfort A., Michel V., Thirion B., Grisel O.,
Blondel M., Prettenhofer P., Weiss R., Dubourg V., Vanderplas J., Passos A.,
Cournapeau D., Brucher M., Perrot M. & Duchesnay E. (2011),
\href{https://jmlr.csail.mit.edu/papers/v12/pedregosa11a.html}{Scikit-learn: Machine Learning in Python}.
\emph{Journal of Machine Learning Research} 12:2825–-2830.
}
