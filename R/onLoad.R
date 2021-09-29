.onLoad <- function(libname = "pxtextmining", pkgname = "pxtextmineR") {

  reticulate::configure_environment(pkgname)

  # Tell the package which Python virtual environment to use
  venv <- Sys.getenv("PXTEXTMINER_PYTHON_VENV")
  venv_manager <- Sys.getenv("PXTEXTMINER_PYTHON_VENV_MANAGER")
  # Better use grepl instead of e.g. `if ("condaenv" %in% venv_manager)` because
  # the supplied venv can be "[e]ither the name of, or the path to, a Python
  # virtual environment." (see reticulate::use_python).
  if (grepl("conda", venv_manager)) {
    reticulate::use_condaenv(condaenv = venv, required = TRUE)
  } else if (grepl("miniconda", venv_manager)) {
    reticulate::use_miniconda(condaenv = venv, required = TRUE)
  } else {
    reticulate::use_virtualenv(virtualenv = venv_manager, required = TRUE) # Here, virtualenv should be the path.
  }

  # Use superassignment to update global reference to imported packages

  on_load_data_load_and_split <<- reticulate::import(
    "pxtextmining.factories.factory_data_load_and_split",
    delay_load = TRUE
  )

  on_load_pipeline <<- reticulate::import(
    "pxtextmining.factories.factory_pipeline",
    delay_load = TRUE
  )

  on_load_model_performance <<- reticulate::import(
    "pxtextmining.factories.factory_model_performance",
    delay_load = TRUE
  )

  # on_load_write_results <<- reticulate::import(
  #   "pxtextmining.factories.factory_write_results",
  #   delay_load = TRUE
  # )

  on_load_predict_text <<- reticulate::import(
    "pxtextmining.factories.factory_predict_unlabelled_text",
    delay_load = TRUE
  )

  on_load_sentiments <<- reticulate::import(
    "pxtextmining.helpers.sentiment_scores",
    delay_load = TRUE
  )

  on_load_cba <<- reticulate::import(
    "pxtextmining.helpers.metrics",
    delay_load = TRUE
  )
}
