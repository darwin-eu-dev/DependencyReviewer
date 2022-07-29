#' Check package dependencies
#'
#' @param packageName Name of package to profile. If NULL current package
#' @param dependencyType Imports, depends, and/ or suggests
#' @param permittedPackages Vector of approved pacakges
#'
#' @return
#' @export
#'
#' @examples
checkDependencies <- function(packageName = NULL,
                              dependencyType = c("Imports", "Depends"),
                              permittedPackages=NULL){

# findDependencies
  if(is.null(packageName)){
  description <-  desc::description$new()
  } else {
  description <- desc::description$new(package=packageName)
  }

  dependencies <- description$get_deps() %>%
    dplyr::filter(.data$type %in% .env$dependencyType) %>%
    dplyr::select("package", "version")

# dependencies that are permitted
if(is.null(permittedPackages)){
  permittedPackages<-getDefaultPermittedPackages()}
permitted <- data.frame(package=permittedPackages)

# check if dependencies are permitted
not_permitted<-dependencies %>%
  dplyr::anti_join(permitted,
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
cli::cli_alert("{.pkg {not_permitted[i]}}")
}
cli::cli_alert_warning("Please open an issue at https://github.com/darwin-eu/IncidencePrevalence to
              request approval for packages (one issue per package).")

}


# check if missing minimum version
missing_min_version<-dependencies %>%
  dplyr::filter(version=="*") %>%
  dplyr::select("package") %>%
  dplyr::arrange(.data$package) %>%
  dplyr::pull()
n_missing_min_version<-length(missing_min_version)
#message
cli::cli_h2("Checking if package{?s} in {dependencyType} have a minimum version specified")
if(n_missing_min_version == 0){
cli::cli_alert_success("All package{?s} in {dependencyType} have a minimum version specified")
} else {
cli::cli_div(theme = list (.alert = list(color = "red")))
cli::cli_alert_warning("Found {n_missing_min_version} package{?s} in {dependencyType} without a minimum version specified")
cli::cli_end()
for(i in 1:n_missing_min_version){
cli::cli_alert("{.pkg {missing_min_version[i]}}")
}
cli::cli_alert_warning("Please add a minimum version for all packages to the description file")
}

invisible(NULL)

}



