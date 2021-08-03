factory_pipeline_r <- function(x, y, tknz = "spacy", ordinal = FALSE,
                               metric = "class_balance_accuracy_score",
                               cv = 5, n_iter = 100, n_jobs = 5, verbose = 3,
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
  verbose <-as.integer(verbose)
  
  re <- pipeline(x, y, tknz, ordinal, metric, cv, n_iter, n_jobs, 
                 verbose, learners, theme)
  
  return(re)
}