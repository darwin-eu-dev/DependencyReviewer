1.2.0 release of DependencyReviewer

Changed following links from:
https://github.com/darwin-eu/DependencyReviewer/actions/workflows/R-CMD-check.yaml/badge.svg
https://github.com/darwin-eu/DependencyReviewer/actions/workflows/R-CMD-check.yaml

to:
https://github.com/darwin-eu-dev/DependencyReviewer/actions/workflows/R-CMD-check.yaml/badge.svg
https://github.com/darwin-eu-dev/DependencyReviewer/actions/workflows/R-CMD-check.yaml

In both README.Rmd and README.md

Built package with following args:
"--compact-vignettes=gs+qpdf"

to pass:
>checking sizes of PDF files under 'inst/doc' ... WARNING
  'gs+qpdf' made some significant size reductions:
     compacted 'Documentation.pdf' from 1596Kb to 632Kb
  consider running tools::compactPDF(gs_quality = "ebook") on these files
