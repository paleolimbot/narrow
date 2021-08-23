
<!-- README.md is generated from README.Rmd. Please edit that file -->

# arrowc

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/paleolimbot/arrowc/branch/master/graph/badge.svg)](https://codecov.io/gh/paleolimbot/arrowc?branch=master)
[![R-CMD-check](https://github.com/paleolimbot/arrowc/workflows/R-CMD-check/badge.svg)](https://github.com/paleolimbot/arrowc/actions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of arrowc is to wrap the [Arrow Data C
API](https://arrow.apache.org/docs/format/CDataInterface.html) and
[Arrow Stream C
API](https://arrow.apache.org/docs/format/CStreamInterface.html) to
provide lightweight Arrow support for R packages to consume and produce
streams of data in Arrow format. Right now it’s just a fun way for me to
learn about Arrow!

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("paleolimbot/arrowc")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(arrowc)

arrow_schema("i")
#> <arrow_schema: 'i'>
#> $format
#> [1] "i"
#> 
#> $name
#> NULL
#> 
#> $flags
#> [1] 0
#> 
#> $children
#> NULL
#> 
#> $dictionary
#> NULL
parse_format("i")
#> $format
#> [1] "i"
#> 
#> $abbreviation
#> [1] "i"
#> 
#> $spec
#> [1] "i"
#> 
#> $description
#> [1] "int32"
#> 
#> $args
#> named list()
```
