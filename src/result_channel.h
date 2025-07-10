#ifndef RESULT_CHANNEL_H
#define RESULT_CHANNEL_H

#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <jni.h>

#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))

struct JNIEnvAttachGuard {
private:
    JavaVM *vm;
    JNIEnv *env;
    bool attached;
public:
    explicit JNIEnvAttachGuard(JavaVM *javaVm);

    ~JNIEnvAttachGuard();

    operator JNIEnv *() const;

    [[nodiscard]] JNIEnv *get() const;

    JNIEnvAttachGuard(const JNIEnvAttachGuard &) = delete;

    JNIEnvAttachGuard &operator=(const JNIEnvAttachGuard &) = delete;

    JNIEnvAttachGuard(JNIEnvAttachGuard &&other) noexcept;

    JNIEnvAttachGuard &operator=(JNIEnvAttachGuard &&other) noexcept;
};

template<typename T>
struct JNILocalRefGuard {
private:
    JNIEnv *env;
    T ref;
public:
    explicit JNILocalRefGuard(JNIEnv *jniEnv, T jniRef) : env(jniEnv), ref(jniRef) {}

    ~JNILocalRefGuard() {
        if (ref && env) {
            env->DeleteLocalRef(ref);
        }
    }

    operator T() const { return ref; }

    [[nodiscard]] T get() const { return ref; }

    JNILocalRefGuard(const JNILocalRefGuard &) = delete;

    JNILocalRefGuard &operator=(const JNILocalRefGuard &) = default;

    JNILocalRefGuard(JNILocalRefGuard &&other) noexcept: env(other.env), ref(other.ref) {
        other.env = nullptr;
        other.ref = nullptr;
    }

    JNILocalRefGuard &operator=(JNILocalRefGuard &&other) noexcept {
        if (this != &other) {
            if (ref && env) {
                env->DeleteLocalRef(ref);
            }

            env = other.env;
            ref = other.ref;
            other.env = nullptr;
            other.ref = nullptr;
        }

        return *this;
    }
};

extern "C" {
typedef enum {
    StatusOk = 0,
    StatusError = 1
} Status;

typedef struct {
    Status status;
    uint8_t *data;
    int32_t size;
} Result;

typedef void (*Callback)(Result *);

FFI_PLUGIN_EXPORT Result *
flutter_result_channel_new_result(Status status, JNIEnv *env, jbyteArray data);

FFI_PLUGIN_EXPORT void flutter_result_channel_free_pointer(void *pointer);
}

FFI_PLUGIN_EXPORT JNILocalRefGuard<jobject>
flutter_result_channel_create_channel(JNIEnv *env, Callback callback);

#endif
