#include "include/result_channel.h"

static JavaVM *g_javaVm = nullptr;
static jclass g_resultChannel = nullptr;

JNIEnvAttachGuard::JNIEnvAttachGuard(JavaVM *javaVm) : vm(javaVm), env(nullptr), attached(false) {
    jint status = vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_6);

    if (status == JNI_EDETACHED) {
        if (vm->AttachCurrentThread(&env, nullptr) != JNI_OK) {
            env = nullptr;
            return;
        }
        attached = true;
    } else if (status != JNI_OK) {
        env = nullptr;
    }
}

JNIEnvAttachGuard::~JNIEnvAttachGuard() {
    if (attached && vm) {
        vm->DetachCurrentThread();
    }
}

JNIEnvAttachGuard::operator JNIEnv *() const { return env; }

JNIEnv *JNIEnvAttachGuard::get() const { return env; }

JNIEnvAttachGuard::JNIEnvAttachGuard(JNIEnvAttachGuard &&other) noexcept: vm(other.vm),
                                                                          env(other.env),
                                                                          attached(other.attached) {
    other.vm = nullptr;
    other.env = nullptr;
    other.attached = false;
}

JNIEnvAttachGuard &JNIEnvAttachGuard::operator=(JNIEnvAttachGuard &&other) noexcept {
    if (this != &other) {
        if (attached && vm) {
            vm->DetachCurrentThread();
        }

        vm = other.vm;
        env = other.env;
        attached = other.attached;
        other.vm = nullptr;
        other.env = nullptr;
        other.attached = false;
    }

    return *this;
}

JNILocalRefGuard::JNILocalRefGuard(JNIEnv *jniEnv, jobject jniRef) : env(jniEnv), ref(jniRef) {}

JNILocalRefGuard::~JNILocalRefGuard() {
    if (ref && env) {
        env->DeleteLocalRef(ref);
    }
}

JNILocalRefGuard::operator jobject() const { return ref; }

jobject JNILocalRefGuard::get() const { return ref; }

JNILocalRefGuard::JNILocalRefGuard(JNILocalRefGuard &&other) noexcept : env(other.env), ref(other.ref) {
    other.env = nullptr;
    other.ref = nullptr;
}

JNILocalRefGuard &JNILocalRefGuard::operator=(JNILocalRefGuard &&other) noexcept {
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

ResultChannelInstanceGuard::ResultChannelInstanceGuard(JNIEnv *jniEnv, Callback callback) : env(
        jniEnv), instance(nullptr) {
    auto callback_ptr = reinterpret_cast<uint64_t>(callback);
    jmethodID jmethodID1 = jniEnv->GetMethodID(g_resultChannel, "<init>", "(J)V");
    instance = jniEnv->NewObject(g_resultChannel, jmethodID1, callback_ptr);
}

ResultChannelInstanceGuard::~ResultChannelInstanceGuard() {
    if (instance && env) {
        env->DeleteLocalRef(instance);
    }
}

ResultChannelInstanceGuard::operator jobject() const { return instance; }

jobject ResultChannelInstanceGuard::get() const { return instance; }

ResultChannelInstanceGuard::ResultChannelInstanceGuard(ResultChannelInstanceGuard &&other) noexcept
        : env(other.env), instance(other.instance) {
    other.env = nullptr;
    other.instance = nullptr;
}

ResultChannelInstanceGuard &
ResultChannelInstanceGuard::operator=(ResultChannelInstanceGuard &&other) noexcept {
    if (this != &other) {
        if (instance && env) {
            env->DeleteLocalRef(instance);
        }

        env = other.env;
        instance = other.instance;
        other.env = nullptr;
        other.instance = nullptr;
    }
    return *this;
}

JavaByteArrayGuard::JavaByteArrayGuard(ResultChannelStatus status, JNIEnv *env, jbyteArray jbyteArray1) : result(
        nullptr) {
    auto instance = reinterpret_cast<ResultNative *>(malloc(sizeof(ResultNative)));
    jsize length = env->GetArrayLength(jbyteArray1);
    auto javaBytes = reinterpret_cast<jbyte *>(env->GetPrimitiveArrayCritical(jbyteArray1,
                                                                              nullptr));
    auto data = reinterpret_cast<uint8_t *>(malloc(length));

    memcpy(data, javaBytes, length);
    env->ReleasePrimitiveArrayCritical(jbyteArray1, javaBytes, JNI_ABORT);

    instance->status = status;
    instance->data = data;
    instance->size = length;
    result = instance;
}

JavaByteArrayGuard::operator ResultNative *() const { return result; }

ResultNative *JavaByteArrayGuard::get() const { return result; }

JavaByteArrayGuard::JavaByteArrayGuard(JavaByteArrayGuard &&other) noexcept: result(other.result) {
    other.result = nullptr;
}

JavaByteArrayGuard &JavaByteArrayGuard::operator=(JavaByteArrayGuard &&other) noexcept {
    if (this != &other) {
        if (result) {
            free(result);
        }

        result = other.result;
        other.result = nullptr;
    }

    return *this;
}

extern "C" {
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *) {
    JNIEnvAttachGuard jniEnvAttachGuard(vm);
    JNIEnv *env = jniEnvAttachGuard;

    JNILocalRefGuard localRefGuard(env, env->FindClass(
            "dev/jonathanvegasp/result_channel/ResultChannel"));

    jobject resultChannel = localRefGuard;
    g_resultChannel = reinterpret_cast<jclass>(env->NewGlobalRef(resultChannel));
    g_javaVm = vm;

    return JNI_VERSION_1_6;
}

JNIEXPORT void JNICALL JNI_OnUnload(JavaVM *, void *) {
    JNIEnvAttachGuard jniEnvAttachGuard(g_javaVm);
    JNIEnv *env = jniEnvAttachGuard;

    if (!env) {
        g_resultChannel = nullptr;
        g_javaVm = nullptr;
        return;
    }

    env->DeleteGlobalRef(g_resultChannel);
    g_resultChannel = nullptr;
    g_javaVm = nullptr;
}

FFI_PLUGIN_EXPORT void flutter_result_channel_free_pointer(void *pointer) {
    if (!pointer) return;

    free(pointer);
}

JNIEXPORT void JNICALL
Java_dev_jonathanvegasp_result_1channel_ResultChannel_success(JNIEnv *env, jclass,
                                                              jlong callback_ptr,
                                                              jbyteArray value) {
    auto callback = reinterpret_cast<Callback>(callback_ptr);

    callback(JavaByteArrayGuard(ResultChannelStatusOk, env, value));
}

JNIEXPORT void JNICALL
Java_dev_jonathanvegasp_result_1channel_ResultChannel_failure(JNIEnv *env, jclass,
                                                              jlong callback_ptr,
                                                              jbyteArray value) {
    auto callback = reinterpret_cast<Callback>(callback_ptr);

    callback(JavaByteArrayGuard(ResultChannelStatusError, env, value));
}
}
