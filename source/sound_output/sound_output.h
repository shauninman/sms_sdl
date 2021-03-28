#ifndef SOUND_OUTPUT_H
#define SOUND_OUTPUT_H

#include <stdint.h>

extern void Sound_Init(void);
extern void Sound_Update(int16_t* restrict sound_buffer, unsigned long len);
extern void Sound_Close(void);
extern void Sound_Pause(void);
extern void Sound_Unpause(void);
#ifdef	SDLSOUND
extern uint32_t Sound_Underrun_Likely();
#endif

#endif
