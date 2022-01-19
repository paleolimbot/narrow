// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

#pragma once

#include <Rinternals.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define ARROW_FLAG_DICTIONARY_ORDERED 1
#define ARROW_FLAG_NULLABLE 2
#define ARROW_FLAG_MAP_KEYS_SORTED 4

struct ArrowSchema {
  // Array type description
  const char* format;
  const char* name;
  const char* metadata;
  int64_t flags;
  int64_t n_children;
  struct ArrowSchema** children;
  struct ArrowSchema* dictionary;

  // Release callback
  void (*release)(struct ArrowSchema*);
  // Opaque producer-specific data
  void* private_data;
};

struct ArrowArray {
  // Array data description
  int64_t length;
  int64_t null_count;
  int64_t offset;
  int64_t n_buffers;
  int64_t n_children;
  const void** buffers;
  struct ArrowArray** children;
  struct ArrowArray* dictionary;

  // Release callback
  void (*release)(struct ArrowArray*);
  // Opaque producer-specific data
  void* private_data;
};

// EXPERIMENTAL: C stream interface

struct ArrowArrayStream {
  // Callback to get the stream type
  // (will be the same for all arrays in the stream).
  //
  // Return value: 0 if successful, an `errno`-compatible error code otherwise.
  //
  // If successful, the ArrowSchema must be released independently from the stream.
  int (*get_schema)(struct ArrowArrayStream*, struct ArrowSchema* out);

  // Callback to get the next array
  // (if no error and the array is released, the stream has ended)
  //
  // Return value: 0 if successful, an `errno`-compatible error code otherwise.
  //
  // If successful, the ArrowArray must be released independently from the stream.
  int (*get_next)(struct ArrowArrayStream*, struct ArrowArray* out);

  // Callback to get optional detailed error information.
  // This must only be called if the last stream operation failed
  // with a non-0 return code.
  //
  // Return value: pointer to a null-terminated character array describing
  // the last error, or NULL if no description is available.
  //
  // The returned pointer is only valid until the next operation on this stream
  // (including release).
  const char* (*get_last_error)(struct ArrowArrayStream*);

  // Release callback: release the stream's own resources.
  // Note that arrays returned by `get_next` must be individually released.
  void (*release)(struct ArrowArrayStream*);

  // Opaque producer-specific data
  void* private_data;
};

static inline struct ArrowSchema* schema_from_xptr(SEXP schema_xptr, const char* arg) {
  if (!Rf_inherits(schema_xptr, "narrow_schema")) {
    Rf_error("`%s` must be an object created with narrow_schema()", arg);
  }

  struct ArrowSchema* schema = (struct ArrowSchema*) R_ExternalPtrAddr(schema_xptr);
  if (schema == NULL) {
    Rf_error("`%s` is an external pointer to NULL", arg); // # nocov
  }

  if (schema->release == NULL) {
    Rf_error("`%s` has already been released and is no longer valid", arg); // # nocov
  }

  return schema;
}

static inline struct ArrowArray* array_data_from_xptr(SEXP array_data_xptr, const char* arg) {
  if (!Rf_inherits(array_data_xptr, "narrow_array_data")) {
    Rf_error("`%s` must be an object created with narrow_array_data()", arg);
  }

  struct ArrowArray* array_data = (struct ArrowArray*) R_ExternalPtrAddr(array_data_xptr);
  if (array_data == NULL) {
    Rf_error("`%s` is an external pointer to NULL", arg); // # nocov
  }

  if (array_data->release == NULL) {
    Rf_error("`%s` has already been released and is no longer valid", arg); // # nocov
  }

  return array_data;
}

static inline struct ArrowArrayStream* array_stream_from_xptr(SEXP array_stream_xptr, const char* arg) {
  if (!Rf_inherits(array_stream_xptr, "narrow_array_stream")) {
    Rf_error("`%s` must be an object created with narrow_array_stream()", arg);
  }

  struct ArrowArrayStream* array_stream = (struct ArrowArrayStream*) R_ExternalPtrAddr(array_stream_xptr);
  if (array_stream == NULL) {
    Rf_error("`%s` is an external pointer to NULL", arg); // # nocov
  }

  if (array_stream->release == NULL) {
    Rf_error("`%s` has already been released and is no longer valid", arg); // # nocov
  }

  return array_stream;
}

#ifdef __cplusplus
}
#endif
