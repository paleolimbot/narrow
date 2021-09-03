
<!-- README.md is generated from README.Rmd. Please edit that file -->

# arrowvctrs

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/paleolimbot/arrowvctrs/branch/master/graph/badge.svg)](https://codecov.io/gh/paleolimbot/arrowvctrs?branch=master)
[![R-CMD-check](https://github.com/paleolimbot/arrowvctrs/workflows/R-CMD-check/badge.svg)](https://github.com/paleolimbot/arrowvctrs/actions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of arrowvctrs is to wrap the [Arrow Data C
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
remotes::install_github("paleolimbot/arrowvctrs")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(arrowvctrs)
(vctr <- as_arrow_vctr(ggplot2::mpg))
#> <arrow_vctr +s[234]>
#> - schema:
#>   <arrow_schema '+s' at 0x14d6e8770>
#>   - format: +s
#>   - name: NULL
#>   - flags: 
#>   - metadata: NULL
#>   - dictionary: NULL
#>   - children[11]:
#>     <arrow_schema 'u' at 0x14d623730>
#>     - format: u
#>     - name: manufacturer
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'u' at 0x11d6ad320>
#>     - format: u
#>     - name: model
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'g' at 0x11d615360>
#>     - format: g
#>     - name: displ
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'i' at 0x11d6a2af0>
#>     - format: i
#>     - name: year
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'i' at 0x11d6c6b60>
#>     - format: i
#>     - name: cyl
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'u' at 0x11d626fd0>
#>     - format: u
#>     - name: trans
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'u' at 0x11d6a2c30>
#>     - format: u
#>     - name: drv
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'i' at 0x11d68fea0>
#>     - format: i
#>     - name: cty
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'i' at 0x11d68b7c0>
#>     - format: i
#>     - name: hwy
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'u' at 0x11d6a79e0>
#>     - format: u
#>     - name: fl
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_schema 'u' at 0x11d691800>
#>     - format: u
#>     - name: class
#>     - flags: 
#>     - metadata: NULL
#>     - dictionary: NULL
#>     - children[0]:
#> - arrays[1]:
#>   <arrow_array at 0x11d6d4020>
#>   - length: 234
#>   - null_count: 0
#>   - offset: 0
#>   - buffers[0]:  list()
#>   - dictionary: NULL
#>   - children[11]:
#>     <arrow_array at 0x14d6f0eb0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : int [1:235] 0 4 8 12 16 20 24 28 32 36 ...
#>       $ : raw [1:1463] 61 75 64 69 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d6bb920>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : int [1:235] 0 2 4 6 8 10 12 14 24 34 ...
#>       $ : raw [1:2455] 61 34 61 34 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d6bca90>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[1]: List of 1
#>       $ : num [1:234] 1.8 1.8 2 2 2.8 2.8 3.1 1.8 1.8 2 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d63a4c0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[1]: List of 1
#>       $ : int [1:234] 1999 1999 2008 2008 1999 1999 2008 1999 1999 2008 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d6cdfb0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[1]: List of 1
#>       $ : int [1:234] 4 4 4 4 6 6 6 4 4 4 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d62b3e0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : int [1:235] 0 8 18 28 36 44 54 62 72 80 ...
#>       $ : raw [1:2026] 61 75 74 6f ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d671660>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : int [1:235] 0 1 2 3 4 5 6 7 8 9 ...
#>       $ : raw [1:234] 66 66 66 66 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d6abcd0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[1]: List of 1
#>       $ : int [1:234] 18 21 20 21 16 18 18 18 16 20 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d62bd90>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[1]: List of 1
#>       $ : int [1:234] 29 29 31 30 26 26 27 26 25 28 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x11d651b50>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : int [1:235] 0 1 2 3 4 5 6 7 8 9 ...
#>       $ : raw [1:234] 70 70 70 70 ...
#>     - dictionary: NULL
#>     - children[0]:
#>     <arrow_array at 0x14d6f03c0>
#>     - length: 234
#>     - null_count: 0
#>     - offset: 0
#>     - buffers[2]: List of 2
#>       $ : int [1:235] 0 7 14 21 28 35 42 49 56 63 ...
#>       $ : raw [1:1462] 63 6f 6d 70 ...
#>     - dictionary: NULL
#>     - children[0]:
```

``` r
tibble::as_tibble(from_arrow_vctr(vctr))
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
