#' Sentiment analysis with Python packages
#'
#' Calculate sentiment indicators from
#' [`TextBlob`](https://textblob.readthedocs.io/en/dev/) and
#' [`vaderSentiment`](https://pypi.org/project/vaderSentiment/).
#'
#' @param x Data frame. The text to run sentiment analysis on.
#'
#' @details This function complements existing sentiment analysis packages in R
#'     (e.g. `tidytext`or `quanteda.sentiment`) with the popular Python
#'     sentiment analysis libraries `TextBlob` and `vaderSentiment`.\cr\cr
#'     `TextBlob` calculates two indicators, namely *polarity* and
#'     *subjectivity*. The polarity score is a float within the range  `[-1, 1]`,
#'     where -1 is for very negative sentiment, +1 is for very  positive
#'     sentiment, and 0 is for neutral sentiment. The subjectivity is a float
#'     within the range `[0, 1]`, where 0 is very objective and 1 is very
#'     subjective. \cr\cr
#'     `vaderSentiment` assigns to the given text three sentiment proportions
#'     (positive, negative and neutral) whose scores sum to 1. It also
#'     calculates a compound score that is a float in `[-1, 1]`, similar to
#'     `TextBlob`'s polarity.
#'
#' @return Data frame. All indicators produced by `TextBlob` (polarity and
#'     subjectivity) and `vaderSentiment` (positive, negative and neutral
#'     sentiments, and compound score).
#'
#' @export
#'
#' @examples
#' sentiments <- pxtextmineR::text_data %>%
#'   dplyr::select(feedback) %>%
#'   pxtextmineR::sentiment_scores_r()
#'
#' head(sentiments)
#' apply(sentiments, 2, range)

sentiment_scores_r <- function(x) {

  sentiments <- on_load_sentiments$sentiment_scores

  re <- sentiments(x)

  return(re)
}
