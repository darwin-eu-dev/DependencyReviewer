
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
#> ── Checking if packages in Imports and Depends have been approved ──
#> 
#> ! Found 12 packages in Imports and Depends that are not
#> approved
#> →   1) desc
#> →   2) DT
#> →   3) funspotr
#> →   4) ggplot2
#> →   5) ggraph
#> →   6) here
#> →   7) igraph
#> →   8) readr
#> →   9) shiny
#> →   10) shinyAce
#> →   11) shinyjs
#> →   12) tidygraph
#> ! Please open an issue at https://github.com/darwin-eu/IncidencePrevalence
#> to request approval for packages (one issue per package).
#> 
#> ── Checking if packages in Imports and Depends require recommended version ──
#> 
#> ! Found 1 package in Imports and Depends with a different
#> version required
#> →   1) dplyr
#> →     currently required: *
#> →     should be: >= 1.0.0
#> ! Please require recommended versions
```

``` r
r_files <- list.files(here::here("R"))

function_use <- summariseFunctionUse(r_files)

head(function_use)
#> # A tibble: 6 × 4
#>   r_file               line pkg   fun      
#>   <chr>               <int> <chr> <chr>    
#> 1 checkDependencies.R    27 base  function 
#> 2 checkDependencies.R    29 dplyr filter   
#> 3 checkDependencies.R    29 base  is.na    
#> 4 checkDependencies.R    30 dplyr rename   
#> 5 checkDependencies.R    31 dplyr left_join
#> 6 checkDependencies.R    33 base  c
```

``` r
function_sub <- function_use %>% 
  filter(!pkg %in% c("unknown", "base", "method"))

fun_counts <- function_sub %>% group_by(fun, pkg, name = "n") %>% tally()

ggplot(
  data = fun_counts, 
  mapping = aes(x = fun, y = n, fill = pkg)) +
  geom_col() +
  facet_wrap(
    vars(pkg), 
    scales = "free_x", 
    ncol = 2) +
  theme_bw() +
  theme(
    legend.position = "none",
    axis.text.x = (element_text(angle = 45, hjust = 1, vjust = 1)))
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

## ShinyApp

Dependency Reviewer now includes a shiny app, which encapsulates all the
functionality available in the package. The app consist of two sections:

1.  Function Review (Function Review and Plot tab)

![Function Review](man/figures/function_review.png) ![Function
Review](man/figures/plot.png)

2.  Dependency Graph (Dependency Graph tab)

![Dependency Graph](man/figures/dependency_graph.png)
