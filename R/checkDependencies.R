#' Check package dependencies
#'
#' @param packageName Name of package to profile. If NULL current package
#' @param dependencyType Imports, depends, and/ or suggests
#'
#' @return
#' @export
#'
#' @examples
checkDependencies <- function(packageName = NULL,
                              dependencyType = c("Imports", "Depends")){

# find dependencies
  if(is.null(packageName)){
  description <-  desc::description$new()
  } else {
  description <- desc::description$new(package=packageName)
  }

  dependencies <- description$get_deps() %>%
    dplyr::filter(.data$type %in% .env$dependencyType) %>%
    dplyr::select("package", "version")

# dependencies that are permitted
permittedPackages<-getDefaultPermittedPackages()

# check if dependencies are permitted
not_permitted<-dependencies %>%
  dplyr::filter(package!="R") %>%
  dplyr::anti_join(permittedPackages,
                   by="package") %>%
  dplyr::select(.data$package) %>%
  dplyr::arrange(.data$package) %>%
  dplyr::pull()
n_not_permitted<-length(not_permitted)
# message
cli::cli_h2("Checking if package{?s} in {dependencyType} have been approved")
if(n_not_permitted == 0){
cli::cli_alert_success("{.strong All package{?s} in {dependencyType} are  already approved}")
} else {
cli::cli_div(theme = list (.alert = list(color = "red")))
cli::cli_alert_warning("Found {n_not_permitted} package{?s} in {dependencyType} that are not approved")
cli::cli_end()

for(i in 1:n_not_permitted){
cli::cli_alert("  {.pkg {i}) {not_permitted[i]}}")
}
cli::cli_alert_warning("Please open an issue at https://github.com/darwin-eu/IncidencePrevalence to
              request approval for packages (one issue per package).")

}

# check if different version in current compared to recommended
diffVersions<-permittedPackages %>%
  dplyr::filter(!is.na(version)) %>%
  dplyr::rename("version_rec"="version") %>%
  dplyr::left_join(dependencies,
            by=c("package")) %>%
  dplyr::filter("version_rec"!="version")

n_diffVersions<-length(diffVersions$package)
#message
cli::cli_h2("Checking if package{?s} in {dependencyType} require recommended version")
if(n_diffVersions == 0){
cli::cli_alert_success("Success! No package{?s} in {dependencyType} require a different version")
} else {
cli::cli_div(theme = list (.alert = list(color = "red")))
cli::cli_alert_warning("Found {n_diffVersions} package{?s} in {dependencyType} with a different version required")
cli::cli_end()
for(i in 1:n_diffVersions){
cli::cli_alert("  {.pkg {i}) {diffVersions[i]}}")
cli::cli_alert("    {.pkg currently required: {diffVersions$version[i]}}")
cli::cli_alert("    {.pkg should be: {diffVersions$version_rec[i]} }")
}
cli::cli_alert_warning("Please require recommended versions")
}

invisible(NULL)

}



