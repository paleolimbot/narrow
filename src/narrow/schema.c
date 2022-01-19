
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <errno.h>

#include "schema.h"

void narrow_schema_release_internal(struct ArrowSchema* schema) {
  if (schema == NULL || schema->release == NULL) {
    return;
  }

  if (schema->format != NULL) free((void*) schema->format);
  if (schema->name != NULL) free((void*) schema->name);
  if (schema->metadata != NULL) free((void*) schema->metadata);

  if (schema->children != NULL) {
    for (uint64_t i = 0; i < schema->n_children; i++) {
      narrow_schema_release_internal(schema->children[i]);
      free(schema->children[i]);
    }

    free(schema->children);
  }

  if (schema->dictionary != NULL) {
    narrow_schema_release_internal(schema->dictionary);
    free(schema->dictionary);
  }

  schema->release = NULL;
  // don't free(schema)!
}

int64_t narrow_schema_metadata_size(const char* metadata) {
  if (metadata == NULL) {
    return 0;
  }

  int64_t pos = 0;
  int32_t n;
  memcpy(&n, metadata + pos, sizeof(int32_t));
  pos += sizeof(int32_t);

  for (int i = 0; i < n; i++) {
    int32_t name_len;
    memcpy(&name_len, metadata + pos, sizeof(int32_t));
    pos += sizeof(int32_t);

    if (name_len > 0) {
      // name = PROTECT(Rf_mkCharLenCE((char*) metadata + pos, name_len, CE_UTF8));
      pos += name_len;
    } else {
      // name = PROTECT(Rf_mkCharCE("", CE_UTF8));
    }

    int32_t value_len;
    memcpy(&value_len, metadata + pos, sizeof(int32_t));
    pos += sizeof(int32_t);

    // SEXP value = PROTECT(Rf_allocarray(RAWSXP, value_len));
    if (value_len > 0) {
      // memcpy(RAW(value), metadata + pos, value_len);
      pos += value_len;
    }
  }

  return pos;
}

void narrow_schema_reset_internal(struct ArrowSchema* schema) {
  schema->format = NULL;
  schema->name = NULL;
  schema->metadata = NULL;
  schema->flags = 0;
  schema->n_children = 0;
  schema->children = NULL;
  schema->dictionary = NULL;
  schema->private_data = NULL;
  schema->release = &narrow_schema_release_internal;
}

int narrow_schema_deep_copy(struct ArrowSchema* out, struct ArrowSchema* schema) {
  if (out == NULL || schema == NULL) {
    return EINVAL;
  }

  narrow_schema_reset_internal(out);

  out->format = (const char*) malloc(strlen(schema->format) + 1);
  memcpy((void*) out->format, schema->format, strlen(schema->format) + 1);
  if (out->format == NULL) {
    out->release(out);
    return ENOMEM;
  }

  if (schema->name != NULL) {
    out->name = (const char*) malloc(strlen(schema->name) + 1);
    if (out->name == NULL) {
      out->release(out);
      return ENOMEM;
    }
    memcpy((void*) out->name, schema->name, strlen(schema->name) + 1);
  }

  int64_t metadata_size = narrow_schema_metadata_size(schema->metadata);
  if (metadata_size > 0) {
    out->metadata = (const char*) malloc(metadata_size);
    if (out->metadata == NULL) {
      out->release(out);
      return ENOMEM;
    }
    memcpy((void*) out->metadata, schema->metadata, metadata_size);
  }

  out->flags = schema->flags;
  out->n_children = schema->n_children;

  int result = 0;

  if (out->n_children > 0) {
    out->children = (struct ArrowSchema**) malloc(sizeof(struct ArrowSchema*) * out->n_children);
    if (out->children == NULL) {
      out->release(out);
      return ENOMEM;
    }

    for (int64_t i = 0; i < out->n_children; i++) {
      out->children[i] = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
      if (out->children[i] == NULL) {
        out->release(out);
        return ENOMEM;
      }

      result = narrow_schema_deep_copy(out->children[i], schema->children[i]);
      if (result != 0) {
        out->release(out);
        return result;
      }
    }
  }

  if (schema->dictionary != NULL) {
    out->dictionary = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
    if (out->dictionary == NULL) {
      out->release(out);
      return ENOMEM;
    }

    result = narrow_schema_deep_copy(out->dictionary, schema->dictionary);
    if (result != 0) {
      out->release(out);
      return result;
    }
  }

  return 0;
}
