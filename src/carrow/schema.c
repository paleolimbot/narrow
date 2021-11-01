
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <errno.h>

#include "schema.h"

void arrow_schema_release_internal(struct ArrowSchema* schema) {
  if (schema == NULL || schema->release == NULL) {
    return;
  }

  if (schema->format != NULL) free((void*) schema->format);
  if (schema->name != NULL) free((void*) schema->name);
  if (schema->metadata != NULL) free((void*) schema->metadata);

  if (schema->children != NULL) {
    for (uint64_t i = 0; i < schema->n_children; i++) {
      arrow_schema_release_internal(schema->children[i]);
    }
  }

  if (schema->dictionary != NULL) {
    arrow_schema_release_internal(schema->dictionary);
  }

  schema->release = NULL;
}

void arrow_schema_reset_internal(struct ArrowSchema* schema) {
  schema->format = NULL;
  schema->name = NULL;
  schema->metadata = NULL;
  schema->flags = 0;
  schema->n_children = 0;
  schema->children = NULL;
  schema->dictionary = NULL;
  schema->private_data = NULL;
  schema->release = &arrow_schema_release_internal;
}

int arrow_schema_copy(struct ArrowSchema* out, struct ArrowSchema* schema) {
  if (out == NULL || schema == NULL) {
    return EINVAL;
  }

  arrow_schema_reset_internal(out);

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

  if (schema->metadata != NULL) {
    out->metadata = (const char*) malloc(strlen(schema->metadata) + 1);
    if (out->metadata == NULL) {
      out->release(out);
      return ENOMEM;
    }
    memcpy((void*) out->metadata, schema->metadata, strlen(schema->metadata) + 1);
  }

  out->flags = schema->flags;
  out->n_children = schema->n_children;

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

      arrow_schema_copy(out->children[i], schema->children[i]);
    }
  }

  if (schema->dictionary != NULL) {
    out->dictionary = (struct ArrowSchema*) malloc(sizeof(struct ArrowSchema));
    if (out->dictionary == NULL) {
      out->release(out);
      return ENOMEM;
    }

    arrow_schema_copy(out->dictionary, schema->dictionary);
  }

  return 0;
}
