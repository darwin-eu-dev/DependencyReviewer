#' Summarise functions used in R package
#'
#' @return tibble
#' @export
#'
#' @examples
summariseFunctionUse <- function(){

r_files<-list.files(here::here("R"))
deps_used<-list()
for(i in 1:length(r_files)){
deps_used[[i]]<-funspotr::spot_funs(file_path = here::here("R",r_files[[i]]),
          show_each_use = TRUE)
}
deps_used<-dplyr::bind_rows(deps_used) %>%
  dplyr::group_by(funs, pkgs) %>%
  dplyr::tally() %>%
  dplyr::arrange(desc(n))

return(deps_used)

}
