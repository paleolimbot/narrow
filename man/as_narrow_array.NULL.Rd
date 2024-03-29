% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/to-array.R
\name{as_narrow_array.NULL}
\alias{as_narrow_array.NULL}
\alias{as_narrow_array.logical}
\alias{as_narrow_array.integer}
\alias{as_narrow_array.double}
\alias{as_narrow_array.character}
\alias{as_narrow_array.factor}
\alias{as_narrow_array.raw}
\alias{as_narrow_array.data.frame}
\title{Convert R objects to Arrow vectors}
\usage{
\method{as_narrow_array}{`NULL`}(x, ..., name = "")

\method{as_narrow_array}{logical}(x, ..., name = "")

\method{as_narrow_array}{integer}(x, ..., name = "")

\method{as_narrow_array}{double}(x, ..., name = "")

\method{as_narrow_array}{character}(x, ..., name = "")

\method{as_narrow_array}{factor}(x, ..., name = "")

\method{as_narrow_array}{raw}(x, ..., name = "")

\method{as_narrow_array}{data.frame}(x, ..., name = "", nullable = FALSE)
}
\arguments{
\item{x}{An object to convert to an \code{\link[=narrow_array]{narrow_array()}}}

\item{...}{Passed to S3 methods}

\item{name}{An optional name}

\item{nullable}{\code{TRUE} if the type is semantically nullable}
}
\value{
An \code{\link[=narrow_array]{narrow_array()}}
}
\description{
These methods return an \code{\link[=narrow_array]{narrow_array()}} for R objects that don't involve
copying or unnecessary allocating. Two excpetions are (1) ALTREP objects,
which will be expanded, and (2) character vectors, which will be converted
to UTF-8 and serialized as a single \code{\link[=raw]{raw()}} vector.
}
\examples{
as_narrow_array(NULL)
as_narrow_array(c(TRUE, FALSE, NA))
as_narrow_array(1:10)
as_narrow_array(c(1.1, 2.2))
as_narrow_array(as.raw(0x00))
as_narrow_array("fish")
as_narrow_array(data.frame(x = 1:10, y = as.raw(1:10)))

}
