
#ifndef BITMASK_H_INCLUDED
#define BITMASK_H_INCLUDED

#include <stdint.h>

static inline int bitmask_value(const unsigned char* bitmask, int64_t i) {
  return 0 != (bitmask[i / 8] & (((unsigned char ) 0x01) << (i % 8)));
}

#endif
