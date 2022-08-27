.PHONY: all clean

RAYLIB_PATH		?= raylib
RAYLIB_RELEASE_PATH 	?= $(RAYLIB_PATH)/src

# Define include paths for required headers: INCLUDE_PATHS
#------------------------------------------------------------------------------------------------
INCLUDE_PATHS = -I. -I$(RAYLIB_PATH)/src -I$(RAYLIB_PATH)/src/external

# Define library paths containing required libs: LDFLAGS
#------------------------------------------------------------------------------------------------
LDFLAGS = -L. -L$(RAYLIB_RELEASE_PATH) -L$(RAYLIB_PATH)/src

# Determine PLATFORM_OS
# No uname.exe on MinGW!, but OS=Windows_NT on Windows!
# ifeq ($(UNAME),Msys) -> Windows
ifeq ($(OS),Windows_NT)
	PLATFORM_OS = WINDOWS
else
    UNAMEOS = $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
    ifeq ($(UNAMEOS),FreeBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),OpenBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),NetBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),DragonFly)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),Darwin)
        PLATFORM_OS = OSX
    endif
endif

# Define default C compiler: CC
#------------------------------------------------------------------------------------------------

CC = gcc

ifeq ($(PLATFORM_OS),OSX)
	# OSX default compiler
	CC = clang
endif
ifeq ($(PLATFORM_OS),BSD)
	# FreeBSD, OpenBSD, NetBSD, DragonFly default compiler
	CC = clang
endif

# Define default make program: MAKE
#------------------------------------------------------------------------------------------------

MAKE ?= make

ifeq ($(PLATFORM_OS),WINDOWS)
	MAKE = mingw32-make
endif

# Define compiler flags: CFLAGS
#------------------------------------------------------------------------------------------------
#  -O1                  defines optimization level
#  -g                   include debug information on compilation
#  -s                   strip unnecessary data from build
#  -Wall                turns on most, but not all, compiler warnings
#  -std=c99             defines C language mode (standard C from 1999 revision)
#  -std=gnu99           defines C language mode (GNU C from 1999 revision)
#  -Wno-missing-braces  ignore invalid warning (GCC bug 53119)
#  -Wno-unused-value    ignore unused return values of some functions (i.e. fread())
#  -D_DEFAULT_SOURCE    use with -std=c99 on Linux and PLATFORM_WEB, required for timespec
CFLAGS = -Wall -std=c99 -D_DEFAULT_SOURCE -Wno-missing-braces -Wunused-result

# Define libraries required on linking: LDLIBS
# NOTE: To link libraries (lib<name>.so or lib<name>.a), use -l<name>
#------------------------------------------------------------------------------------------------
ifeq ($(PLATFORM_OS),WINDOWS)
    # Libraries for Windows desktop compilation
    # NOTE: WinMM library required to set high-res timer resolution
    LDLIBS = -lraylib -lopengl32 -lgdi32 -lwinmm
endif
ifeq ($(PLATFORM_OS),LINUX)
    # Libraries for Debian GNU/Linux desktop compiling
    # NOTE: Required packages: libegl1-mesa-dev
    LDLIBS = -lraylib -lGL -lm -lpthread -ldl -lrt

    # On X11 requires also below libraries
    LDLIBS += -lX11
    # NOTE: It seems additional libraries are not required any more, latest GLFW just dlopen them
    #LDLIBS += -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor

    # On Wayland windowing system, additional libraries requires
    ifeq ($(USE_WAYLAND_DISPLAY),TRUE)
        LDLIBS += -lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon
    endif
    # Explicit link to libc
    ifeq ($(RAYLIB_LIBTYPE),SHARED)
        LDLIBS += -lc
    endif
    
    # TODO: On ARM 32bit arch, miniaudio requires atomics library
    LDLIBS += -latomic
endif
ifeq ($(PLATFORM_OS),OSX)
    # Libraries for OSX 10.9 desktop compiling
    # NOTE: Required packages: libopenal-dev libegl1-mesa-dev
    LDLIBS = -lraylib -framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo
endif
ifeq ($(PLATFORM_OS),BSD)
    # Libraries for FreeBSD, OpenBSD, NetBSD, DragonFly desktop compiling
    # NOTE: Required packages: mesa-libs
    LDLIBS = -lraylib -lGL -lpthread -lm

    # On XWindow requires also below libraries
    LDLIBS += -lX11 -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor
endif

EXE_NAME = roguelite

# Source files
SRCS = src/main.c
OBJS = $(SRCS:.c=.o)

all: $(EXE_NAME)

$(EXE_NAME): $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDE_PATHS) -o $(EXE_NAME) $(OBJS) $(LDFLAGS) $(LDLIBS)

.c.o:	
	$(CC) $(CFLAGS) $(INCLUDE_PATHS) -c $<  -o $@

# Clean everything
clean:
ifeq ($(PLATFORM_OS),WINDOWS)
	del $(OBJS)
	del *.exe /s
endif
ifeq ($(PLATFORM_OS),LINUX)
	find . -type f -executable -delete
	rm -fv $(OBJS)
endif
ifeq ($(PLATFORM_OS),OSX)
	find . -type f -perm +ugo+x -delete
	rm -f $(OBJS)
endif
