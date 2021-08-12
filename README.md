# pxtextmineR

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

An R wrapper for Python's [`pxtextmining`](https://pypi.org/project/pxtextmining/) 
library- a pipeline to classify text-based patient experience data.

**Function documentation**: https://nhs-r-community.github.io/pxtextmineR/.

Package `pxtextmineR` does not wrap _everything_ from `pxtextmining`, but 
selected functions that will offer R users new opportunities for modelling. For 
example, the whole [`Scikit-learn`](https://scikit-learn.org/stable/index.html) 
(Pedregosa et al., 2011) text classification pipeline is wrapped, as 
well as helper functions for e.g. sentiment analysis with Python's 
[`textBlob`](https://textblob.readthedocs.io/en/dev/) and
[`vaderSentiment`](https://pypi.org/project/vaderSentiment/).

How does wrapper work? It uses R package [`reticulate`](https://rstudio.github.io/reticulate/),
which provides tools for interoperability between Python and R.

## Installation and setup
There are a few things that need to be done to install and set up `pxtextmineR`.

1. Run `devtools::install_github("nhs-r-community/pxtextmineR")` in the R 
   console.
1. Create a Python _virtual environment_. If not familiar with virtual 
   environments please take a look at [this](https://docs.python.org/3/tutorial/venv.html) 
   and [this](https://virtualenv.pypa.io/en/stable/). R package `reticulate` has 
   functions to create a Python virtual environment via the R console. Refer to 
   `reticulate::conda_create` and `reticulate::virtualenv_create`. For example, 
   if using [Conda](https://docs.conda.io/en/latest/index.html#), run 
  
   `reticulate::conda_create("r-reticulate")`
  
   where "r-reticulate" is the name of `reticulate`'s default virtual environment.
   Using this default virtual environment for `pxtextmineR` is strongly 
   recommended because it makes the setup so much easier. According to the 
   `reticulate` authors' [own words](https://rstudio.github.io/reticulate/articles/package.html)
   "_[i]t’s much more straightforward for users if there is a common environment 
   used by R packages [...]_"
1. Tell `reticulate` to use the "r-reticulate" virtual environment:
  
   `reticulate::use_condaenv("r-reticulate"", required = TRUE)`
1. Install Python package [`pxtextmining`](https://pypi.org/project/pxtextmining/) 
   in "r-reticulate":
  
   `reticulate::py_install(envname = "r-reticulate", packages = "pxtextmining", pip = TRUE)`
1. We also need to install a couple of 
   [`spaCy`](https://github.com/explosion/spacy-models) models in "r-reticulate". 
   These are obtained from URL links and thus need to be installed separately. 
   In the R console run:
   
   ```
   system("pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-2.3.1/en_core_web_sm-2.3.1.tar.gz")
   
   system("pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_lg-2.3.1/en_core_web_lg-2.3.1.tar.gz")
   ```

All steps in one go:

```
devtools::install_github("nhs-r-community/pxtextmineR")
# If not using Conda, comment out the next two lines and uncomment the two lines 
# following them.
reticulate::conda_create("r-reticulate")
reticulate::use_condaenv("r-reticulate"", required = TRUE)
# reticulate::virtualenv_create("r-reticulate")
# reticulate::use_virtualenv("r-reticulate"", required = TRUE)
reticulate::py_install(envname = "r-reticulate", packages = "pxtextmining", pip = TRUE)
system("pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-2.3.1/en_core_web_sm-2.3.1.tar.gz")
system("pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_lg-2.3.1/en_core_web_lg-2.3.1.tar.gz")

```

## References
Pedregosa F., Varoquaux G., Gramfort A., Michel V., Thirion B., Grisel O., 
Blondel M., Prettenhofer P., Weiss R., Dubourg V., Vanderplas J., Passos A., 
Cournapeau D., Brucher M., Perrot M. & Duchesnay E. (2011), 
[Scikit-learn: Machine Learning in Python](https://jmlr.csail.mit.edu/papers/v12/pedregosa11a.html). 
_Journal of Machine Learning Research_ 12:2825--2830.
