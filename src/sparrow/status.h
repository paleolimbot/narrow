
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct ArrowStatus {
  int code;
  char message[8096];
};

void sparrow_status_reset(struct ArrowStatus* status);
void sparrow_status_set_error(struct ArrowStatus* status, int code, const char* fmt, ...);

#define RETURN_IF_NOT_OK(_value) if ((_value)->code != 0) return (_value)->code

#ifdef __cplusplus
}
#endif
