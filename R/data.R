#' Patient experience data
#'
#' A dataset containing patient feedback from NHS Nottinghamshire Healthcare NHS
#' Foundation trust and partner trusts about the patients' experience while in
#' care.
#'
#' @format A data frame with 3 variables:
#' \describe{
#'   \item{label}{
#'       A group of tags indicating what the patient is talking about. For
#'       example, is it about the facilities, their communication with staff or
#'       is it something about privacy?
#'    }
#'   \item{criticality}{A group of ordinal tags in [-5, 5] indicating how
#'       positive or negative an experience of care is- from negative ("The
#'       staff were very rude") to positive ("I felt immediately at home").}
#'   \item{feedback}{The feedback text.}
#'   ...
#' }
#' @source \url{https://github.com/CDU-data-science-team/pxtextmining/blob/main/datasets/text_data.csv}
"text_data"
