#' Stem Words
#'
#' Stem a character vector of words using the selected algorithm.
#'
#' @param words,texts character vector of words.
#' @param algorithm string with the name of the algorithm to be used. One of \code{"hunspell"},
#' \code{"rslp"}, \code{"porter"} and \code{modified-hunspell}.
#' @param ... other arguments passed to the algorithms.
#' @param n_char minimum number of characters of words to be stemmed. Not used by \code{ptstem_words}.
#' @param ignore vector of words and regex's to igore. Words are wrapped around \code{stringr::fixed()} for words
#' like 'banana' dont't get excluded when you ignore 'ana'. Also elements are considered a regex when
#' they contain at least one punctuation symbol.
#' @param complete wheter to complete words or not i.e. change all words with the same stem by the word that appears
#' the most with that stem.
#'
#' @details
#' You can choose wheter to complete words or not using the \code{complete} argument. By default all
#' algorithms are completing stems. For hunspell, it's better to always use \code{complete = TRUE} since even
#' when using complete = FALSE it will complete words.
#'
#' Complete finds the stem that appears the most in the full corpus. That's why it should not be used when
#' you are stemming in parallel.
#'
#' @examples
#' words <- c("balões", "aviões", "avião", "gostou", "gosto", "gostaram")
#' ptstem_words(words, "hunspell")
#' ptstem_words(words)
#' ptstem_words(words, algorithm = "porter", complete = FALSE)
#'
#' texts <- c("coma frutas pois elas fazem bem para a saúde.",
#' "não coma doces, eles fazem mal para os dentes.")
#' ptstem(texts, "hunspell")
#' ptstem(texts, n_char = 5)
#' ptstem(texts, "porter", n_char = 4, complete = FALSE)
#' ptstem(words, ignore = "av.*") # words starting with "av" are not stemmed
#'
#'
#' @rdname ptstem
#'
#' @export
ptstem_words <- function(words, algorithm = "rslp", complete = T, ...){
  stopifnot(algorithm %in% c("hunspell", "rslp", "porter", "modified-hunspell"))
  stopifnot(complete %in% c(TRUE, FALSE) & (!is.numeric(complete)))
  if (algorithm == "hunspell") {
    return(stem_hunspell(words, complete = complete, ...))
  }
  if (algorithm == "rslp") {
    return(stem_rslp(words, complete = complete, ...))
  }
  if (algorithm == "porter") {
    return(stem_porter(words, complete = complete, ...))
  }
  if (algorithm == "modified-hunspell") {
    return(stem_modified_hunspell(words, complete = complete, ...))
  }
}

#' @rdname ptstem
#' @export
ptstem <- function(texts, algorithm = "rslp", n_char = 3, complete = T, ignore = NULL, ...){
  stopifnot(algorithm %in% c("hunspell", "rslp", "porter", "modified-hunspell"))
  stopifnot(complete %in% c(TRUE, FALSE) & (!is.numeric(complete)))

  # if is null -> NA
  if(!is.null(ignore)) {
    if(is.na(ignore)) {
      stop("ignore must not be NA, try NULL instead.")
    }
  }

  words <- extract_words(texts)
  words <- words[stringr::str_length(words) >= n_char]
  if (!is.null(ignore)) {
    ignored_regex <- ignore[stringr::str_detect(ignore, "[:punct:]")]
    ignored_words <- stringr::fixed(ignore[!stringr::str_detect(ignore, "[:punct:]")])
    if (length(ignored_regex) > 0) {
      words <- words[!stringr::str_detect(words, ignored_regex)]
    }
    if (length(ignored_words) > 0) {
      words <- words[!stringr::str_detect(words, ignored_words)]
    }
  }
  if (length(words) > 0) {
    words_s <- ptstem_words(words, algorithm = algorithm, complete = complete, ...)
    names(words_s) <- sprintf("\\b%s\\b", words)
    words_s <- words_s[!is.na(words_s)]
    texts <- stringr::str_replace_all(texts, words_s)
  }
  return(texts)
}


