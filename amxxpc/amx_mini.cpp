#include "amx.h"

#if BYTE_ORDER==BIG_ENDIAN
static void swap32(uint32_t *v)
{
  unsigned char *s = (unsigned char *)v;
  unsigned char t;
  t=s[0]; s[0]=s[3]; s[3]=t;
  t=s[1]; s[1]=s[2]; s[2]=t;
}
#endif

uint32_t * AMXAPI amx_Align32(uint32_t *v)
{
  #if BYTE_ENDIAN==BIG_ENDIAN
    swap32(v);
  #endif
  return v;
}

uint16_t * AMXAPI amx_Align16(uint16_t *v)
{
  #if BYTE_ENDIAN==BIG_ENDIAN
    unsigned char *s = (unsigned char *)v;
    unsigned char t;
    t=s[0]; s[0]=s[1]; s[1]=t;
  #endif
  return v;
}

int AMXAPI amx_GetString(char *dest, const cell *source, int use_wchar, size_t size)
{
  if ((ucell)*source > UNPACKEDMAX) {
    int i;
    for (i=sizeof(cell)-1; i>=0; i--) {
      char c = (char)((ucell)source[0] >> (i*8));
      if (c==0) break;
      if (size > 1) { *dest++ = c; size--; }
    }
  } else {
    while (*source != 0) {
      if (size > 1) { *dest++ = (char)*source; size--; }
      source++;
    }
  }
  *dest = '\0';
  return 0;
}
