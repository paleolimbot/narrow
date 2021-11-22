
<!-- README.md is generated from README.Rmd. Please edit that file -->

# carrow

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/paleolimbot/carrow/branch/master/graph/badge.svg)](https://codecov.io/gh/paleolimbot/carrow?branch=master)
[![R-CMD-check](https://github.com/paleolimbot/carrow/workflows/R-CMD-check/badge.svg)](https://github.com/paleolimbot/carrow/actions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of carrow is to wrap the [Arrow Data C
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
remotes::install_github("paleolimbot/carrow")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(carrow)
(carray <- as_carrow_array(ggplot2::mpg))
#> <carrow_array +s[234]>
#> - schema:
#>   <carrow_schema '+s' at 0x137ed0e90>
#>   - format: +s
#>   - name: NULL
#>   - flags: 
#>   - metadata:  list()
#>   - dictionary: NULL
#>   - children[11]:
#>     <carrow_schema 'u' at 0x147f20180>
#>     - format: u
#>     - name: manufacturer
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'u' at 0x147f531a0>
#>     - format: u
#>     - name: model
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'g' at 0x147fd7d40>
#>     - format: g
#>     - name: displ
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'i' at 0x147f630b0>
#>     - format: i
#>     - name: year
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'i' at 0x147fa7b80>
#>     - format: i
#>     - name: cyl
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'u' at 0x147feb2d0>
#>     - format: u
#>     - name: trans
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'u' at 0x147f96120>
#>     - format: u
#>     - name: drv
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'i' at 0x147f91ff0>
#>     - format: i
#>     - name: cty
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'i' at 0x147fab2f0>
#>     - format: i
#>     - name: hwy
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'u' at 0x147f25be0>
#>     - format: u
#>     - name: fl
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_schema 'u' at 0x137ef10d0>
#>     - format: u
#>     - name: class
#>     - flags: 
#>     - metadata:  list()
#>     - dictionary: NULL
#>     - children[0]:
#> - array:
#>   <carrow_array at 0x137ed0990>
#>   - length: 234
#>   - null_count: 0
#>   - offset: 0
#>   - buffers[1]: List of 1
#>     $ : NULL
#>   - dictionary: NULL
#>   - children[11]:
#>     <carrow_array at 0x147fac050>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[3]: List of 3
#>       $ : NULL
#>       $ : int [1:235] 0 4 8 12 16 20 24 28 32 36 ...
#>       $ : raw [1:1463] 61 75 64 69 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147fc72a0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[3]: List of 3
#>       $ : NULL
#>       $ : int [1:235] 0 2 4 6 8 10 12 14 24 34 ...
#>       $ : raw [1:2455] 61 34 61 34 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147f9e400>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : NULL
#>       $ : num [1:234] 1.8 1.8 2 2 2.8 2.8 3.1 1.8 1.8 2 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147fdf980>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : NULL
#>       $ : int [1:234] 1999 1999 2008 2008 1999 1999 2008 1999 1999 2008 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147f70940>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : NULL
#>       $ : int [1:234] 4 4 4 4 6 6 6 4 4 4 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147f28ef0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[3]: List of 3
#>       $ : NULL
#>       $ : int [1:235] 0 8 18 28 36 44 54 62 72 80 ...
#>       $ : raw [1:2026] 61 75 74 6f ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147f9ae90>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[3]: List of 3
#>       $ : NULL
#>       $ : int [1:235] 0 1 2 3 4 5 6 7 8 9 ...
#>       $ : raw [1:234] 66 66 66 66 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147f54b20>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : NULL
#>       $ : int [1:234] 18 21 20 21 16 18 18 18 16 20 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147f05f20>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : NULL
#>       $ : int [1:234] 29 29 31 30 26 26 27 26 25 28 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x147f6c930>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[3]: List of 3
#>       $ : NULL
#>       $ : int [1:235] 0 1 2 3 4 5 6 7 8 9 ...
#>       $ : raw [1:234] 70 70 70 70 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <carrow_array at 0x137ebe1e0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[3]: List of 3
#>       $ : NULL
#>       $ : int [1:235] 0 7 14 21 28 35 42 49 56 63 ...
#>       $ : raw [1:1462] 63 6f 6d 70 ...
#>     - dictionary: NULL
#>     - children[0]:
```

``` r
tibble::as_tibble(from_carrow_array(carray))
#> # A tibble: 234 × 11
#>    manufacturer model      displ  year   cyl trans drv     cty   hwy fl    class
#>    <chr>        <chr>      <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
#>  1 audi         a4           1.8  1999     4 auto… f        18    29 p     comp…
#>  2 audi         a4           1.8  1999     4 manu… f        21    29 p     comp…
#>  3 audi         a4           2    2008     4 manu… f        20    31 p     comp…
#>  4 audi         a4           2    2008     4 auto… f        21    30 p     comp…
#>  5 audi         a4           2.8  1999     6 auto… f        16    26 p     comp…
#>  6 audi         a4           2.8  1999     6 manu… f        18    26 p     comp…
#>  7 audi         a4           3.1  2008     6 auto… f        18    27 p     comp…
#>  8 audi         a4 quattro   1.8  1999     4 manu… 4        18    26 p     comp…
#>  9 audi         a4 quattro   1.8  1999     4 auto… 4        16    25 p     comp…
#> 10 audi         a4 quattro   2    2008     4 manu… 4        20    28 p     comp…
#> # … with 224 more rows
```
