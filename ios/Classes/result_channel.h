#ifndef RESULT_CHANNEL_H
#define RESULT_CHANNEL_H

#include <stdint.h>

#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))

typedef enum {
    ResultChannelStatusOk = 0,
    ResultChannelStatusError = 1
} ResultChannelStatus;

typedef struct {
    ResultChannelStatus status;
    uint8_t *data;
    int32_t size;
} ResultNative;

typedef void (*Callback)(ResultNative *);

FFI_PLUGIN_EXPORT void flutter_result_channel_free_pointer(void *pointer);

#endif
