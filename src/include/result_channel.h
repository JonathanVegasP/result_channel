#ifndef RESULT_CHANNEL_H
#define RESULT_CHANNEL_H

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include <jni.h>

#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))

#define JAVA_CLASS "java/lang/Class"

#define JAVA_CLASS_LOADER "java/lang/ClassLoader"

#define METHOD_GET_CLASS_LOADER "getClassLoader"

#define RETURN_GET_CLASS_LOADER "()L" JAVA_CLASS_LOADER ";"

#define METHOD_LOAD_CLASS "loadClass"

#define RETURN_LOAD_CLASS "(Ljava/lang/String;)Ljava/lang/Class;"

#define RESULT_CHANNEL_CLASS "dev/jonathanvegasp/result_channel/ResultChannel"

#define CONSTRUCTOR "<init>"

#define RESULT_CHANNEL_CONSTRUCTOR_ARGS "(J)V"

#define BYTE_BUFFER_CLASS "java/nio/ByteBuffer"

#define CALL_VOID_METHOD "()V"

#define CALL_VOID_WITH_ARGS_METHOD "(L" BYTE_BUFFER_CLASS ";)V"

#define CALL_RETURN_METHOD "()L" BYTE_BUFFER_CLASS ";"

#define CALL_RETURN_WITH_ARGS_METHOD "(L" BYTE_BUFFER_CLASS ";)L" BYTE_BUFFER_CLASS ";"

#define CALL_ASYNC_METHOD "(L" RESULT_CHANNEL_CLASS ";)V"

#define CALL_ASYNC_WITH_ARGS_METHOD "(L" RESULT_CHANNEL_CLASS ";L" BYTE_BUFFER_CLASS ";)V"


typedef enum {
    ResultChannelStatusOk = 0,
    ResultChannelStatusError = 1
} ResultChannelStatus;

typedef struct {
    ResultChannelStatus status;
    uint8_t *data;
    size_t size;
} ResultNative;

typedef void (*Callback)(ResultNative *);


FFI_PLUGIN_EXPORT void flutter_result_channel_register_class(const char *java_class_name);

FFI_PLUGIN_EXPORT void
flutter_result_channel_call_static_void(const char *java_class_name, const char *method_name);

FFI_PLUGIN_EXPORT void
flutter_result_channel_call_static_void_with_args(const char *java_class_name,
                                                  const char *method_name,
                                                  const ResultNative *args);

FFI_PLUGIN_EXPORT ResultNative *
flutter_result_channel_call_static_return(const char *java_class_name, const char *method_name);

FFI_PLUGIN_EXPORT ResultNative *
flutter_result_channel_call_static_return_with_args(const char *java_class_name,
                                                    const char *method_name,
                                                    const ResultNative *args);

FFI_PLUGIN_EXPORT void
flutter_result_channel_call_static_void_async(const char *java_class_name, const char *method_name,
                                              Callback callback);

FFI_PLUGIN_EXPORT void
flutter_result_channel_call_static_void_async_with_args(const char *java_class_name,
                                                        const char *method_name, Callback callback,
                                                        ResultNative *args);

FFI_PLUGIN_EXPORT void flutter_result_channel_free_pointer(void *pointer);

#endif
