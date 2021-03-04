#	for TRIMUI , based from Makefile.bittboy
#PROFILE = YES
PROFILE = APPLY

PRGNAME     = sms_sdl
CC			= /opt/trimui/bin/arm-unknown-linux-gnueabi-gcc

# Possible choices : rs97, k3s (PAP K3S), sdl, amini, fbdev
PORT = trimui
# Possible choices : alsa, pulse (pulseaudio), oss, sdl12 (SDL 1.2 sound output), portaudio, libao
SOUND_OUTPUT = sdl12
# Possible choices : crabemu_sn76489 (less accurate, GPLv2), maxim_sn76489 (somewhat problematic license but good accuracy)
SOUND_ENGINE = maxim_sn76489
# Possible choices : z80 (accurate but proprietary), eighty (EightyZ80's core, GPLv2)
Z80_CORE = z80
SCALE2X_UPSCALER = 1
ZIP_SUPPORT = 1

SRCDIR		= ./source ./source/cpu_cores/$(Z80_CORE) ./source/sound ./source/unzip
SRCDIR		+= ./source/scalers ./source/ports/$(PORT) ./source/sound/$(SOUND_ENGINE) ./source/sound_output/$(SOUND_OUTPUT)
VPATH		= $(SRCDIR)
SRC_C		= $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.c))
SRC_CP		= $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.cpp))
OBJ_C		= $(notdir $(patsubst %.c, %.o, $(SRC_C)))
OBJ_CP		= $(notdir $(patsubst %.cpp, %.o, $(SRC_CP)))
OBJS		= $(OBJ_C) $(OBJ_CP)

CFLAGS		= -Ofast -fdata-sections -ffunction-sections -fsingle-precision-constant -fno-PIC -flto -march=armv5te -mtune=arm926ej-s
# SMS Plus GX suffers from alignment issues so setting these to 1 helps.
CFLAGS		+= -falign-functions=1 -falign-jumps=1 -falign-loops=1 -falign-labels=1
CFLAGS		+= -DALIGN_DWORD
CFLAGS		+= -DLSB_FIRST -std=gnu99
CFLAGS		+= -Isource -Isource/cpu_cores/$(Z80_CORE) -Isource/scalers -Isource/ports/$(PORT) -I./source/sound -Isource/unzip -Isource/sdl -Isource/sound/$(SOUND_ENGINE) -Isource/sound_output

SRCDIR		+= ./source/text/fb
CFLAGS		+= -Isource/text/fb

ifeq ($(SOUND_ENGINE), maxim_sn76489)
CFLAGS 		+= -DMAXIM_PSG
endif

ifeq ($(ZIP_SUPPORT), 0)
CFLAGS 		+= -DNOZIP_SUPPORT
endif

ifeq ($(SCALE2X_UPSCALER), 1)
CFLAGS 		+= -DSCALE2X_UPSCALER
CFLAGS		+= -Isource/scale2x
SRCDIR		+= ./source/scale2x
endif

#LDFLAGS     = -nodefaultlibs -lc -lgcc -lSDL -no-pie -Wl,--as-needed -Wl,--gc-sections -s -flto
LDFLAGS     = -lc -lgcc -lm -lSDL -Wl,--gc-sections -s -flto

ifeq ($(SOUND_OUTPUT), portaudio)
LDFLAGS		+= -lportaudio
endif
ifeq ($(SOUND_OUTPUT), libao)
LDFLAGS		+= -lao
endif
ifeq ($(SOUND_OUTPUT), alsa)
LDFLAGS		+= -lasound
endif
ifeq ($(SOUND_OUTPUT), pulse)
LDFLAGS		+= -lpulse -lpulse-simple
endif
ifeq ($(SOUND_OUTPUT), sdl12)
CFLAGS		+= -DNONBLOCKING_AUDIO
endif

ifeq ($(PROFILE), YES)
CFLAGS 		+= -fprofile-generate -fprofile-dir=/mnt/SDCARD/profile/sms
LDFLAGS		+= -lgcov
else ifeq ($(PROFILE), APPLY)
CFLAGS		+= -fprofile-use -fprofile-dir=./profile -fbranch-probabilities
endif

LDFLAGS += -lSDL_TTF -lSDL_Image -ldl # required for libmmenu

# Rules to make executable
$(PRGNAME): $(OBJS)  
	$(CC) $(CFLAGS) -o $(PRGNAME) $^ $(LDFLAGS)

$(OBJ_C) : %.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(PRGNAME) *.o
