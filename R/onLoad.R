.onLoad <- function(libname, pkgname) {

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
}
