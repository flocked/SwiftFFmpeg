#include "avutil_shim.h"

#include <stdarg.h>
#include <stdio.h>

static void swift_ffmpeg_log_callback(
    void *context,
    int level,
    const char *format,
    va_list args
) {
    vfprintf(stderr, format, args);
}

void swift_initialize_ffmpeg_logging(void) {
    av_log_set_callback(swift_ffmpeg_log_callback);
}

__attribute__((constructor))
static void swift_initialize_ffmpeg_logging_on_load(void) {
    swift_initialize_ffmpeg_logging();
}
