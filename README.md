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

How does the wrapper work? It uses R package [`reticulate`](https://rstudio.github.io/reticulate/),
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
  
   where `r-reticulate` is the name of `reticulate`'s default virtual environment.
   Using this default virtual environment for `pxtextmineR` is strongly 
   recommended because it makes the setup so much easier. According to the 
   `reticulate` authors' [own words](https://rstudio.github.io/reticulate/articles/package.html)
   "_[i]t’s much more straightforward for users if there is a common environment 
   used by R packages [...]_"
1. Tell `reticulate` to use the `r-reticulate` virtual environment:
  
   `reticulate::use_condaenv("r-reticulate", required = TRUE)`
1. Install Python package [`pxtextmining`](https://pypi.org/project/pxtextmining/) 
   in `r-reticulate`:
  
   `reticulate::py_install(envname = "r-reticulate", packages = "pxtextmining", pip = TRUE)`
1. We also need to install a couple of 
   [`spaCy`](https://github.com/explosion/spacy-models) models in `r-reticulate`. 
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
reticulate::use_condaenv("r-reticulate", required = TRUE)
# reticulate::virtualenv_create("r-reticulate")
# reticulate::use_virtualenv("r-reticulate", required = TRUE)
reticulate::py_install(envname = "r-reticulate", packages = "pxtextmining", pip = TRUE)
system("pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-2.3.1/en_core_web_sm-2.3.1.tar.gz")
system("pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_lg-2.3.1/en_core_web_lg-2.3.1.tar.gz")

```

### A NOTE OF CAUTION!
The installation instructions above did not work in all machines on which the 
installation process was tested. There were two problems:

1. In some machines `reticulate` would simply 
   refuse to install in virtual environment `r-reticulate` the version of 
`Scikit-learn` that `pxtextmining` uses (v 0.23.2).
1. When trying to use a virtual environment other than `r-reticulate` (i.e.    `reticulate::use_condaenv("<some_other_virtual_environment>", required = TRUE)`),
   the behaviour of `reticulate` was confusing. On the one hand, it would run 
   `pxtextmineR` functions using the user-specified virtual environment. However, 
   on the other hand, when running commands to build e.g. function documentation 
   with R package `pkgdown`, `reticulate` would automatically set `r-reticulate` as 
   the default environment, causing the code to break.

We have opted for a more "invasive" [approach](https://github.com/nhs-r-community/pxtextmineR/commit/44fdce8ddf0a53f57d57936f78b4a477484d2ba0) to fix this problem so that users can use any virtual environment 
with no issues. This requires the following steps:

1. Create a Python virtual environment using e.g. Anaconda, Miniconda or a 
   Virtual Python Environment.
1. In it, install `pxtextmining` and the `spaCy` models:
   ```
   pip install pxtextmining
   system("pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-2.3.1/en_core_web_sm-2.3.1.tar.gz")
   system("pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_lg-2.3.1/en_core_web_lg-2.3.1.tar.gz")

   ```
1. Use a text editor to open your `.Renviron` file, normally located in 
   `~/.Renviron`, and add the following lines:

    ```
    PXTEXTMINER_PYTHON_VENV_MANAGER=name_or_path_to_venv_manager
    PXTEXTMINER_PYTHON_VENV=name_of_venv
    ```
 
    where "name_of_venv" should be replaced by the name of the virtual 
    and "name_or_path_to_venv_manager" should be replaced by the name or path 
    to the virtual environment manager. If using Conda or Miniconda, replace 
    "name_or_path_to_venv_manager" with "conda" or "miniconda" (unquoted) 
    respectively. If  using a Virtual Python Environment, replace 
    "name_or_path_to_venv_manager" with the path to the virtual environment's 
    `python.exe` e.g. `/home/user/venvs/myvenv/bin/python`.
1. Good idea to restart R Studio.
1. Run `devtools::install_github("nhs-r-community/pxtextmineR")` in the R 
   console.
1. Again, good idea to restart R Studio. If there are error messages that the 
   user-specified Python environment cannot be set, close and re-open R Studio.
   
## References
Pedregosa F., Varoquaux G., Gramfort A., Michel V., Thirion B., Grisel O., 
Blondel M., Prettenhofer P., Weiss R., Dubourg V., Vanderplas J., Passos A., 
Cournapeau D., Brucher M., Perrot M. & Duchesnay E. (2011), 
[Scikit-learn: Machine Learning in Python](https://jmlr.csail.mit.edu/papers/v12/pedregosa11a.html). 
_Journal of Machine Learning Research_ 12:2825--2830.
