
#' Array streams from functions
#'
#' @param schema A [carrow_schema()]
#' @param fun An R function whose return value is converted to
#'   a [carrow_array()] and passed to the caller.
#' @param validate Use `FALSE` to skip validation of the output of the function
#'   against `schema`.
#'
#' @return An object of class "carrow_array_stream"
#' @export
#'
carrow_array_stream_function <- function(schema, fun, validate = TRUE) {
  schema <- as_carrow_schema(schema)
  fun <- match.fun(fun)
  force(validate)

  # Easier and better for backtraces to pass an environment + a call
  # plus we need a wrapper that won't longjmp until the base caller
  # is wrapped in a C-level try/catch
  wrapper_env <- new.env(parent = emptyenv())
  wrapper_env$fun_wrapper <- function() {
    tryCatch({
      result <- fun()

      # make sure result is compatible with the schema or NULL
      if (is.null(result)) {
        result
      } else if (inherits(result, "carrow_array_data")) {
        carrow_array(schema, result)
        result
      } else {
        result_array <- as_carrow_array(result)
        if (validate) {
          result_array$schema <- schema
        }
        result_array$array_data
      }
    }, error = function(e) {
      structure(conditionMessage(e), class = "carrow_array_stream_error")
    })
  }

  .Call(carrow_c_function_array_stream, schema, call("fun_wrapper"), wrapper_env)
}
