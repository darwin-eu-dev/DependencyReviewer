
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DependencyReviewer

<!-- badges: start -->

[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

## Installation

You can install the development version of DependencyReviewer like so:

``` r
install.packages("remotes")
remotes::install_github("darwin-eu/DependencyReviewer")
```

## Example

Check whether dependencies in the description file are approved and
whether the required version matches the current recommendation.

``` r
library(DependencyReviewer)
library(CodelistGenerator)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)
```

Without any options set, it will review the package you are currently
inside:

``` r
checkDependencies()
#> 
#> -- Checking if packages in Imports and Depends have been approved --
#> 
#> ! Found 1 package in Imports and Depends that are not approved
#> >   1) desc
#> ! Please open an issue at https://github.com/darwin-eu/IncidencePrevalence to
#> request approval for packages (one issue per package).
#> 
#> -- Checking if packages in Imports and Depends require recommended version --
#> 
#> ! Found 1 package in Imports and Depends with a different version required
#> >   1) dplyr
#> >     currently required: *
#> >     should be: >= 1.0.0
#> ! Please require recommended versions
```

``` r
# Get files in package ./R/ directory
r_files <- list.files(here::here("R"))

# Filter files; _playground.R is a script to test functionality and not part 
# of the package.
r_files <- r_files[!r_files %in% c("_playground.R")]

# Summarise function use of r_files
function_use <- summariseFunctionUse(r_files)

# Filter packages on != unknown, base, or methods
function_use %>%
  filter(pkg != "unknown") %>%
  filter(pkg != "base") %>%
  filter(pkg != "methods")

ggplot(
  data = function_use, 
  mapping = aes(fun, n, fill = pkg)) +
  geom_col() +
  facet_wrap(
    vars(pkg), 
    scales = "free_x", ncol = 2) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />
