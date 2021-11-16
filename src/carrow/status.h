
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct ArrowStatus {
  int code;
  char message[8096];
};

void arrow_status_reset(struct ArrowStatus* status);
void arrow_status_set_error(struct ArrowStatus* status, int code, const char* fmt, ...);

#define ARROW_OK_OR_RETURN(_value) if ((_value)->code != 0) return code;

#ifdef __cplusplus
}
#endif
