#' Complete Stems
#' @param words character vector of words
#' @param stems character vector of stems
complete_stems <- function(words, stems){
  stem_word <- dplyr::data_frame(words = words, stems = stems) %>%
    dplyr::group_by(words) %>%
    dplyr::mutate(n_word = n()) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(stems) %>%
    dplyr::summarise(new_stems = dplyr::first(words, order_by = -n_word)) %>%
    dplyr::select(stems, new_stems)
  return(stem_word)
}