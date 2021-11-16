
#include <stdarg.h>
#include <stdio.h>

#include "status.h"


void arrow_status_reset(struct ArrowStatus* status) {
  status->code = 0;
  status->message[0] = '\0';
}

void arrow_status_set_error(struct ArrowStatus* status, int code, const char* fmt, ...) {
  va_list args;
  va_start(args, fmt);
  vsnprintf(status->message, 8096, fmt, args);
  va_end(args);
}
