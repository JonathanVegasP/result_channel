#ifndef RESULT_CHANNEL_H
#define RESULT_CHANNEL_H

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <jni.h>

#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))

extern "C" {
struct FFI_PLUGIN_EXPORT JNIEnvAttachGuard {
private:
    const JavaVM *vm;
    JNIEnv *env;
    bool attached;
public:
    explicit JNIEnvAttachGuard(const JavaVM *javaVm);

    ~JNIEnvAttachGuard();

    operator JNIEnv *() const;

    [[nodiscard]] JNIEnv *get() const;

    JNIEnvAttachGuard(const JNIEnvAttachGuard &) = delete;

    JNIEnvAttachGuard &operator=(const JNIEnvAttachGuard &) = delete;

    JNIEnvAttachGuard(JNIEnvAttachGuard &&other) noexcept;

    JNIEnvAttachGuard &operator=(JNIEnvAttachGuard &&other) noexcept;
};

struct FFI_PLUGIN_EXPORT JNILocalRefGuard {
private:
    const JNIEnv *env;
    jobject ref;
public:
    explicit JNILocalRefGuard(const JNIEnv *jniEnv, jobject jniRef);

    ~JNILocalRefGuard();

    operator jobject() const;

    [[nodiscard]] jobject get() const;

    JNILocalRefGuard(const JNILocalRefGuard &) = delete;

    JNILocalRefGuard &operator=(const JNILocalRefGuard &) = default;

    JNILocalRefGuard(JNILocalRefGuard &&other) noexcept;

    JNILocalRefGuard &operator=(JNILocalRefGuard &&other) noexcept;
};

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

struct FFI_PLUGIN_EXPORT ResultChannelInstanceGuard {
private:
    const JNIEnv *env;
    jobject instance;
public:
    explicit ResultChannelInstanceGuard(const JNIEnv *env, Callback callback);

    ~ResultChannelInstanceGuard();

    operator jobject() const;

    [[nodiscard]] jobject get() const;

    ResultChannelInstanceGuard(const ResultChannelInstanceGuard &) = delete;

    ResultChannelInstanceGuard &operator=(const ResultChannelInstanceGuard &) = delete;

    ResultChannelInstanceGuard(ResultChannelInstanceGuard &&other) noexcept;

    ResultChannelInstanceGuard &operator=(ResultChannelInstanceGuard &&other) noexcept;
};

struct FFI_PLUGIN_EXPORT JavaByteArrayGuard {
private:
    ResultNative *result;
public:
    explicit JavaByteArrayGuard(ResultChannelStatus status, const JNIEnv *env, jbyteArray jbyteArray1);

    operator ResultNative *() const;

    [[nodiscard]] ResultNative *get() const;

    JavaByteArrayGuard(const JavaByteArrayGuard &) = delete;

    JavaByteArrayGuard &operator=(const JavaByteArrayGuard &) = default;

    JavaByteArrayGuard(JavaByteArrayGuard &&other) noexcept;

    JavaByteArrayGuard &operator=(JavaByteArrayGuard &&other) noexcept;
};

FFI_PLUGIN_EXPORT void flutter_result_channel_free_pointer(void *pointer);
}

#endif
