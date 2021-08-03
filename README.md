
# pxtextmineR

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

An R wrapper for Python's [`pxtextmining`](https://pypi.org/project/pxtextmining/) 
library- a pipeline to classify text-based patient experience data.

Package `pxtextmineR` does not wrap _everything_ from `pxtextmining`, but 
selected functions that will offer R users new opportunities for modelling. For 
example, the whole [`Scikit-learn`](https://scikit-learn.org/stable/index.html) 
(Pedregosa et al., 2011) text classification pipeline is wrapped, as 
well as helper functions for e.g. sentiment analysis with Python's 
[`textBlob`](https://textblob.readthedocs.io/en/dev/) and
[`vaderSentiment`](https://pypi.org/project/vaderSentiment/).

## References
Pedregosa F., Varoquaux G., Gramfort A., Michel V., Thirion B., Grisel O., 
Blondel M., Prettenhofer P., Weiss R., Dubourg V., Vanderplas J., Passos A., 
Cournapeau D., Brucher M., Perrot M. & Duchesnay E. (2011), 
[Scikit-learn: Machine Learning in Python](https://jmlr.csail.mit.edu/papers/v12/pedregosa11a.html). 
_Journal of Machine Learning Research_ 12:2825–2830
