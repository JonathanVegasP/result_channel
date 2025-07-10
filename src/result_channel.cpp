#include "result_channel.h"

static JavaVM *g_javaVm = nullptr;
static jclass g_resultChannel = nullptr;

JNIEnvAttachGuard::JNIEnvAttachGuard(JavaVM *javaVm) : vm(javaVm), env(nullptr), attached(false) {
    if (!vm) return;

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

extern "C" {
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *) {
    JNIEnvAttachGuard jniEnvAttachGuard(vm);
    JNIEnv *env = jniEnvAttachGuard;

    if (!env) {
        return JNI_EVERSION;
    }

    JNILocalRefGuard<jclass> localRefGuard(env, env->FindClass(
            "dev/jonathanvegasp/result_channel/ResultChannel"));

    jclass resultChannel = localRefGuard;

    g_resultChannel = static_cast<jclass>(env->NewGlobalRef(resultChannel));

    g_javaVm = vm;

    return JNI_VERSION_1_6;
}

JNIEXPORT void JNICALL JNI_OnUnload(JavaVM *, void *) {
    JNIEnvAttachGuard jniEnvAttachGuard(g_javaVm);
    JNIEnv *env = jniEnvAttachGuard;

    if (!env) {
        g_javaVm = nullptr;
        return;
    }

    env->DeleteGlobalRef(g_resultChannel);
    g_resultChannel = nullptr;
    g_javaVm = nullptr;
}

FFI_PLUGIN_EXPORT void free_c_mem(void *pointer) {
    if (!pointer) return;

    free(pointer);
}

JNIEXPORT void JNICALL
Java_dev_jonathanvegasp_result_1channel_ResultChannel_success(JNIEnv *env,
                                                              jclass ,
                                                              jlong callback_ptr,
                                                              jbyteArray value) {
    JNILocalRefGuard<jbyteArray> localRefGuard(env, value);

    auto callback = reinterpret_cast<Callback>(callback_ptr);

    if (!callback) {
        return;
    }

    jsize length = env->GetArrayLength(value);

    jbyte *rawBytes = env->GetByteArrayElements(value, nullptr);

    auto *newValues = reinterpret_cast<uint8_t *>(malloc(length));

    memcpy(newValues, rawBytes, length);

    env->ReleaseByteArrayElements(value, rawBytes, JNI_ABORT);

    callback(StatusOk, newValues, length);
}

JNIEXPORT void JNICALL
Java_dev_jonathanvegasp_result_1channel_ResultChannel_failure(JNIEnv *env, jclass,
                                                              jlong callback_ptr,
                                                              jbyteArray value) {
    JNILocalRefGuard<jbyteArray> localRefGuard(env, value);

    auto callback = reinterpret_cast<Callback>(callback_ptr);

    if (!callback) {
        return;
    }

    jsize length = env->GetArrayLength(value);

    jbyte *bytes = env->GetByteArrayElements(value, nullptr);

    auto *newValues = reinterpret_cast<uint8_t *>(malloc(length));

    memcpy(newValues, bytes, length);

    env->ReleaseByteArrayElements(value, bytes, JNI_ABORT);

    callback(StatusError, newValues, length);
}
}

JNILocalRefGuard<jobject> flutter_result_channel_create_channel(JNIEnv *env, Callback callback) {
    if (!env || !g_resultChannel) {
        return JNILocalRefGuard<jobject>(nullptr, nullptr);
    }

    auto callback_ptr = reinterpret_cast<uint64_t>(callback);
    jmethodID jmethodID1 = env->GetMethodID(g_resultChannel, "<init>", "(J)V");

    return JNILocalRefGuard<jobject>(env,
                                     env->NewObject(g_resultChannel, jmethodID1, callback_ptr));
}
