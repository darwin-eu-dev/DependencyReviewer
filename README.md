
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DependencyReviewer

<!-- badges: start -->

[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

## Installation

You can install the development version of DependencyReviewer like so:

``` r
install.packages("remotes")
remotes::install_github("darwin-eu/CodelistGenerator")
```

## Example

Check whether dependencies in the description file are approved and
whether a minimum version has been specified.

``` r
library(DependencyReviewer)
library(CodelistGenerator)

checkDependencies(packageName = "CodelistGenerator")
#> 
#> -- Checking if packages in Imports and Depends have been approved --
#> 
#> v All packages in Imports and Depends are  already approved
#> 
#> -- Checking if packages in Imports and Depends have a minimum version specified --
#> 
#> ! Found 1 package in Imports and Depends without a minimum version specified
#> > glue
#> ! Please add a minimum version for all packages to the description file
```
