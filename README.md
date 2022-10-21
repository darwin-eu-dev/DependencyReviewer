
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
library(dplyr)
library(ggplot2)
library(pander)
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

pander(head(function_use))
```

|       r_file        | line |  pkg  |    fun    |
|:-------------------:|:----:|:-----:|:---------:|
| checkDependencies.R |  27  | base  | function  |
| checkDependencies.R |  29  | dplyr |  filter   |
| checkDependencies.R |  29  | base  |   is.na   |
| checkDependencies.R |  30  | dplyr |  rename   |
| checkDependencies.R |  31  | dplyr | left_join |
| checkDependencies.R |  33  | base  |     c     |

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

![Function Review](man/figures/function_review.png) This panel shows the
locations of functions per file. The file can be changed in the top
left. Packages that are found in this file can be filtered out, if
desired.

In a table on the left all functions are shown, with what package
they’re from and in what line they’re found in the file. On the right
the file being investigated is shown.

![Function Review](man/figures/plot.png) The *Plot* panel shows bar
plots per package which are found in the investigated file. Filtering
can be used to exclude packages.

2.  Dependency Graph (Dependency Graph tab)

![Dependency Graph](man/figures/dependency_graph.png) In the final tab
panel a graph is shown of all packages and their dependencies. On the
left hand side several options are shown. 1) *Layout* the layout of the
graph; 2) *iterations* Number of iterations (if applicable for the
selected layout) 3) *Number of Dependency layers* the amount of
dependencies shown, with *their* dependencies, as a slider, or numeric
value.
