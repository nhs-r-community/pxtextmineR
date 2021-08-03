text_classification_pipeline_r <- 
  function(filename, 
           target, predictor, test_size = 0.33,
           ordinal = FALSE,
           tknz = "spacy",
           metric = "class_balance_accuracy_score",
           cv = 5, n_iter = 100, n_jobs = 5, verbose = 3,
           learners = c("SGDClassifier"),
           objects_to_save = c(
             "pipeline",
             "tuning results",
             "predictions",
             "accuracy per class",
             "index - training data",
             "index - test data",
             "bar plot"
           ),
           save_objects_to_server = FALSE,
           save_objects_to_disk = FALSE,
           save_pipeline_as = "default",
           results_folder_name = "results",
           reduce_criticality = FALSE,
           theme = NULL, 
           python_setup = FALSE,
           sys_setenv, 
           which_python, 
           which_venv,
           venv_name
  ) {
    
    if (python_setup) {
      experienceAnalysis::prep_python(sys_setenv, which_python, which_venv,
                                      venv_name)
    }
    
    cv <- reticulate::r_to_py(as.integer(cv))
    n_iter <- reticulate::r_to_py(as.integer(n_iter))
    n_jobs <- reticulate::r_to_py(as.integer(n_jobs))
    verbose <- reticulate::r_to_py(as.integer(verbose))
    
    pxpipeline <- reticulate::py_run_string(
      "from pxtextmining.pipelines.text_classification_pipeline import text_classification_pipeline"
    )$text_classification_pipeline
    
    re <- pxpipeline(filename, 
                     target, 
                     predictor, 
                     test_size,
                     ordinal,
                     tknz,
                     metric,
                     cv, n_iter, n_jobs, verbose,
                     learners,
                     objects_to_save,
                     save_objects_to_server,
                     save_objects_to_disk,
                     save_pipeline_as,
                     results_folder_name,
                     reduce_criticality,
                     theme)
    
    return(re)
}



