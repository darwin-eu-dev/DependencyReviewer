1.2.3 release of DependencyReviewer

Bases on feedback of CRAN test results, the functions:

1. getDefaultPermittedPackages
2. checkDependencies
3. getGraphData

Will return NULL values and print out a message when ran offline. These functions require online resources to function. Tests for these functions have `skip_if_offline()` added, to prevent any tests from failing when run offline.
