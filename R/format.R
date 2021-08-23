
#' Parse Arrow format strings
#'
#' @param format A
#'   [format string](https://arrow.apache.org/docs/format/CDataInterface.html#data-type-description-format-strings).
#'
#' @return A [list()] with elements:
#'   - `format`: The input string
#'   - `abbreviation`: The short name of the type
#'   - `spec`: The parsing pattern for the type
#'   - `description`: The human-readable name of the type
#'   - `args`: A [list()] of key/value pairs of type arguments
#' @export
#'
#' @examples
#' parse_format("i")
#' parse_format("w:128")
#' parse_format("+ud:1,2,3")
#'
parse_format <- function(format) {
  stopifnot(length(format) == 1)

  pattern_matches <- vapply(
    formats_internal_regex,
    function(x) grepl(x, format),
    logical(1)
  )

  if (!any(pattern_matches, na.rm = TRUE)) {
    stop(
      sprintf("'%s' did not match any known Arrow format string specification", format),
      call. = FALSE
    )
  }

  pattern_which <- which(pattern_matches)

  spec <- names(formats_internal_spec)[pattern_which]
  abbreviation <- gsub("[^\\+a-zA-Z0-9].*", "", spec)
  description <- unname(formats_internal_spec[pattern_which])
  pattern <- formats_internal_regex[pattern_which]
  arg_names <- formats_internal_args[[pattern_which]]
  arg_match <- regexec(pattern, format)[[1]]
  arg_values <- substr(
    rep_len(format, length(arg_names)),
    arg_match[2],
    arg_match[2] + attr(arg_match, "match.length")[2] - 1
  )
  names(arg_values) <- arg_names
  arg_values <- as.list(arg_values)

  # apply parsing to values
  int_args <- c("precision", "scale", "bitwidth", "n_bytes", "n_items")
  arg_values[arg_names %in% int_args] <- lapply(arg_values[arg_names %in% int_args], as.integer)
  arg_values[arg_names == "type_ids"] <- lapply(
    arg_values[arg_names == "type_ids"],
    function(x) as.integer(strsplit(x, ",", fixed = TRUE)[[1]])
  )

  list(
    format = format,
    abbreviation = abbreviation,
    spec = spec,
    description = description,
    args = arg_values
  )
}


formats_internal_spec <- c(
  "n" = "null",
  "b" = "boolean",
  "c" = "int8",
  "C" = "uint8",
  "s" = "int16",
  "S" = "uint16",
  "i" = "int32",
  "I" = "uint32",
  "l" = "int64",
  "L" = "uint64",
  "e" = "float16",
  "f" = "float32",
  "g" = "float64",
  "z" = "binary",
  "Z" = "large binary",
  "u" = "utf-8 string",
  "U" = "large utf-8 string",

  "d:{precision},{scale}" = "decimal128",
  "d:{precision},{scale},{bitwidth}" = "decimal bitwidth",
  "w:{n_bytes}" = "fixed-width binary",

  "tdD" = "date32 [days]",
  "tdm" = "date64 [milliseconds]",
  "tts" = "time32 [seconds]",
  "ttm" = "time32 [milliseconds]",
  "ttu" = "time64 [microseconds]",
  "ttn" = "time64 [nanoseconds]",
  "tss:{timezone}" = "timestamp [seconds] with timezone",
  "tsm:{timezone}" = "timestamp [milliseconds] with timezone",
  "tsu:{timezone}" = "timestamp [microseconds] with timezone",
  "tsn:{timezone}" = "timestamp [nanoseconds] with timezone",
  "tDs" = "duration [seconds]",
  "tDm" = "duration [milliseconds]",
  "tDu" = "duration [microseconds]",
  "tDn" = "duration [nanoseconds]",
  "tiM" = "interval [months]",
  "tiD" = "interval [days, time]",

  "+l" = "list",
  "+L" = "large list",
  "+w:{n_items}" = "fixed-sized list",
  "+s" = "struct",
  "+m" = "map",
  "+ud:{type_ids}" = "dense union with type ids",
  "+us:{type_ids}" = "sparse union with type ids"
)

formats_internal_args <- lapply(
  names(formats_internal_spec),
  function(x) {
    match <- gregexpr("\\{.+?\\}", x)
    args <- lapply(match, function(m) {
      if (isTRUE(m == -1)) {
        character(0)
      } else {
        substr(rep(x, length(m)), m + 1, m + attr(m, "match.length") - 2)
      }
    })

    unlist(args)
  }
)

formats_internal_arg_regex <- c(
  "precision" = "([0-9]+)",
  "scale" = "([0-9]+)",
  "bitwidth" = "([0-9]+)",
  "n_bytes" = "([0-9]+)",
  "timezone" = "([A-Za-z0-9_/-]*)",
  "n_items" = "([0-9]+)",
  "type_ids" = "(([0-9]+)(,[0-9]+)*)"
)

formats_internal_regex <- gsub("^\\+", "\\\\+", names(formats_internal_spec))
for (arg in names(formats_internal_arg_regex)) {
  formats_internal_regex <- gsub(
    paste0("{", arg, "}"),
    formats_internal_arg_regex[arg],
    formats_internal_regex,
    fixed = TRUE
  )
}
formats_internal_regex <- paste0("^", formats_internal_regex, "$")
