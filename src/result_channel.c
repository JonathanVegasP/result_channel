#include "include/result_channel.h"

static JavaVM *g_jvm = NULL;
static jclass g_resultChannel = NULL;
static jmethodID g_constructorResultChannel = NULL;
static jobject g_appClassLoader = NULL;
static jmethodID g_loadClassLoader = NULL;

typedef struct HashNode {
    char *key;
    unsigned int hash;
    size_t key_length;
    void *value;
    struct HashNode *next;
} HashNode;

typedef struct HashMap {
    HashNode **buckets;
    size_t size;
    size_t count;
} HashMap;

static HashMap *hashmap_create() {
    HashMap *map = malloc(sizeof(HashMap));

    map->size = 16;
    map->count = 0;
    map->buckets = malloc(16 * sizeof(HashNode *));

    return map;
}

static unsigned int djb2_hash(const char *str) {
    unsigned int hash = 5381;

    while (*str) {
        hash = ((hash << 5) + hash) + (unsigned char) (*str);
        str++;
    }

    return hash;
}

static void hashmap_resize(HashMap *map) {
    const size_t old_size = map->size;
    const size_t new_size = old_size << 1;

    HashNode **old_buckets = map->buckets;
    HashNode **new_buckets = malloc(new_size * sizeof(HashNode *));

    for (size_t i = 0; i < old_size; i++) {
        HashNode *current = old_buckets[i];
        while (current) {
            HashNode *next = current->next;
            const unsigned int new_index = current->hash & (new_size - 1);
            current->next = NULL;
            new_buckets[new_index] = current;
            current = next;
        }
    }

    free(old_buckets);
    map->buckets = new_buckets;
    map->size = new_size;
}

static void hashmap_put(HashMap *map, const char *key, jclass *value) {
    if ((float) map->count > (float) map->size * 0.75F) {
        hashmap_resize(map);
    }

    const unsigned int hash = djb2_hash(key);
    const unsigned int index = hash & (map->size - 1);
    const size_t len = strlen(key);

    HashNode *current = map->buckets[index];

    while (current) {
        if (current->key_length == len && memcmp(current->key, key, len) == 0) {
            current->value = value;
            return;
        }
        current = current->next;
    }

    HashNode *new_node = malloc(sizeof(HashNode));

    char *new_key = malloc(len + 1);

    memcpy(new_key, key, len + 1);

    new_node->key = new_key;
    new_node->key_length = len;
    new_node->hash = hash;
    new_node->value = value;
    new_node->next = map->buckets[index];
    map->buckets[index] = new_node;
    map->count++;
}

static void *hashmap_get(HashMap *map, const char *key) {
    const unsigned int hash = djb2_hash(key);
    const unsigned int index = hash & (map->size - 1);
    HashNode *current = map->buckets[index];
    const size_t len = strlen(key);

    while (current) {
        if (current->key_length == len &&
            memcmp(current->key, key, len) == 0) {
            return current->value;
        }

        current = current->next;
    }

    return NULL;
}

static void hashmap_free(HashMap *map, JNIEnv *env) {
    const size_t size = map->size;
    HashNode **buckets = map->buckets;

    for (size_t i = 0; i < size; i++) {
        HashNode *current = buckets[i];
        while (current) {
            HashNode *temp = current;
            current = current->next;
            free(temp->key);
            (*env)->DeleteGlobalRef(env, temp->value);
            free(temp);
        }
    }
    free(buckets);
    free(map);
}

static HashMap *g_map = NULL;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    g_map = hashmap_create();

    g_jvm = vm;

    JNIEnv *env;

    (*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6);

    jclass result_channel = (*env)->FindClass(env, RESULT_CHANNEL_CLASS);

    g_constructorResultChannel = (*env)->GetMethodID(env, result_channel, CONSTRUCTOR,
                                                     RESULT_CHANNEL_CONSTRUCTOR_ARGS);

    jclass classClass = (*env)->FindClass(env, JAVA_CLASS);

    jmethodID getClassLoader = (*env)->GetMethodID(env, classClass, METHOD_GET_CLASS_LOADER,
                                                   RETURN_GET_CLASS_LOADER);

    (*env)->DeleteLocalRef(env, classClass);

    jobject localClassLoader = (*env)->CallObjectMethod(env, result_channel, getClassLoader);

    g_resultChannel = (*env)->NewGlobalRef(env, result_channel);

    (*env)->DeleteLocalRef(env, result_channel);

    g_appClassLoader = (*env)->NewGlobalRef(env, localClassLoader);

    (*env)->DeleteLocalRef(env, localClassLoader);

    jclass classLoaderClass = (*env)->FindClass(env, JAVA_CLASS_LOADER);

    g_loadClassLoader = (*env)->GetMethodID(env, classLoaderClass, METHOD_LOAD_CLASS,
                                            RETURN_LOAD_CLASS);

    (*env)->DeleteLocalRef(env, classLoaderClass);

    return JNI_VERSION_1_6;
}

JNIEXPORT void JNICALL JNI_OnUnload(JavaVM *vm, void *reserved) {
    JNIEnv *env;

    (*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6);

    (*env)->DeleteGlobalRef(env, g_resultChannel);

    (*env)->DeleteGlobalRef(env, g_appClassLoader);

    hashmap_free(g_map, env);

    g_map = NULL;

    g_jvm = NULL;

    g_resultChannel = NULL;

    g_appClassLoader = NULL;

    g_loadClassLoader = NULL;
}

static JNIEnv *get_env(JavaVM *jvm) {
    JNIEnv *env;

    jint status = (*jvm)->GetEnv(jvm, (void **) &env, JNI_VERSION_1_6);

    if (status == JNI_EDETACHED) {
        (*jvm)->AttachCurrentThread(jvm, &env, NULL);
    }

    return env;
}

FFI_PLUGIN_EXPORT void flutter_result_channel_register_class(const char *java_class_name) {
    JNIEnv *env = get_env(g_jvm);

    jstring name = (*env)->NewStringUTF(env, java_class_name);

    jclass local_cls = (*env)->CallObjectMethod(env, g_appClassLoader, g_loadClassLoader, name);

    (*env)->DeleteLocalRef(env, name);

    jclass cls = (*env)->NewGlobalRef(env, local_cls);

    (*env)->DeleteLocalRef(env, local_cls);

    hashmap_put(g_map, java_class_name, cls);
}

static ResultNative *new_result_native(JNIEnv *env, jobject byteBuffer,
                                       ResultChannelStatus status) {
    ResultNative *instance = malloc(sizeof(ResultNative));
    uint8_t *javaBytes = (*env)->GetDirectBufferAddress(env, byteBuffer);
    jlong length = (*env)->GetDirectBufferCapacity(env, byteBuffer);
    uint8_t *data = malloc(length);

    memcpy(data, javaBytes, length);

    instance->status = status;
    instance->data = data;
    instance->size = length;

    return instance;
}

FFI_PLUGIN_EXPORT void
flutter_result_channel_call_static_void(const char *java_class_name, const char *method_name) {
    jclass cls = hashmap_get(g_map, java_class_name);
    JNIEnv *env = get_env(g_jvm);
    jmethodID methodId = (*env)->GetStaticMethodID(env, cls, method_name, CALL_VOID_METHOD);
    (*env)->CallStaticVoidMethod(env, cls, methodId);
}

FFI_PLUGIN_EXPORT void
flutter_result_channel_call_static_void_with_args(const char *java_class_name,
                                                  const char *method_name,
                                                  const ResultNative *args) {
    jclass cls = hashmap_get(g_map, java_class_name);
    JNIEnv *env = get_env(g_jvm);
    jmethodID methodId = (*env)->GetStaticMethodID(env, cls, method_name,
                                                   CALL_VOID_WITH_ARGS_METHOD);
    jobject byte_buffer = (*env)->NewDirectByteBuffer(env, args->data, (jlong) args->size);
    (*env)->CallStaticVoidMethod(env, cls, methodId, byte_buffer);
    (*env)->DeleteLocalRef(env, byte_buffer);
}

FFI_PLUGIN_EXPORT ResultNative *
flutter_result_channel_call_static_return(const char *java_class_name, const char *method_name) {
    jclass cls = hashmap_get(g_map, java_class_name);
    JNIEnv *env = get_env(g_jvm);
    jmethodID methodId = (*env)->GetStaticMethodID(env, cls, method_name, CALL_RETURN_METHOD);
    jobject byte_buffer = (*env)->CallStaticObjectMethod(env, cls, methodId);
    ResultNative *result = new_result_native(env, byte_buffer, ResultChannelStatusOk);
    (*env)->DeleteLocalRef(env, byte_buffer);
    return result;
}

FFI_PLUGIN_EXPORT ResultNative *
flutter_result_channel_call_static_return_with_args(const char *java_class_name,
                                                    const char *method_name,
                                                    const ResultNative *args) {
    jclass cls = hashmap_get(g_map, java_class_name);
    JNIEnv *env = get_env(g_jvm);
    jmethodID methodId = (*env)->GetStaticMethodID(env, cls, method_name,
                                                   CALL_RETURN_WITH_ARGS_METHOD);
    jobject byte_buffer_args = (*env)->NewDirectByteBuffer(env, args->data, (jlong) args->size);
    jobject byte_buffer = (*env)->CallStaticObjectMethod(env, cls, methodId, byte_buffer_args);
    (*env)->DeleteLocalRef(env, byte_buffer_args);
    ResultNative *result = new_result_native(env, byte_buffer, ResultChannelStatusOk);
    (*env)->DeleteLocalRef(env, byte_buffer);
    return result;
}

FFI_PLUGIN_EXPORT void
flutter_result_channel_call_static_void_async(const char *java_class_name, const char *method_name,
                                              Callback callback) {
    jclass cls = hashmap_get(g_map, java_class_name);
    JNIEnv *env = get_env(g_jvm);
    jmethodID methodId = (*env)->GetStaticMethodID(env, cls, method_name, CALL_ASYNC_METHOD);
    jobject result_channel = (*env)->NewObject(env, g_resultChannel, g_constructorResultChannel,
                                               (jlong) callback);
    (*env)->CallStaticVoidMethod(env, cls, methodId, result_channel);
    (*env)->DeleteLocalRef(env, result_channel);
}

FFI_PLUGIN_EXPORT void
flutter_result_channel_call_static_void_async_with_args(const char *java_class_name,
                                                        const char *method_name, Callback callback,
                                                        ResultNative *args) {
    jclass cls = hashmap_get(g_map, java_class_name);
    JNIEnv *env = get_env(g_jvm);
    jmethodID methodId = (*env)->GetStaticMethodID(env, cls, method_name,
                                                   CALL_ASYNC_WITH_ARGS_METHOD);
    jobject result_channel = (*env)->NewObject(env, g_resultChannel, g_constructorResultChannel,
                                               (jlong) callback);
    jobject byte_buffer_args = (*env)->NewDirectByteBuffer(env, args->data, (jlong) args->size);
    (*env)->CallStaticVoidMethod(env, cls, methodId, result_channel, byte_buffer_args);
    (*env)->DeleteLocalRef(env, result_channel);
    (*env)->DeleteLocalRef(env, byte_buffer_args);
}

FFI_PLUGIN_EXPORT void flutter_result_channel_free_pointer(void *pointer) {
    if (!pointer) return;

    free(pointer);
}

JNIEXPORT void JNICALL
Java_dev_jonathanvegasp_result_1channel_ResultChannel_success(JNIEnv *env, jclass cls,
                                                              jlong callback_ptr,
                                                              jobject value) {

    ResultNative *instance = new_result_native(env, value, ResultChannelStatusOk);
    Callback callback = (Callback) callback_ptr;
    callback(instance);
}

JNIEXPORT void JNICALL
Java_dev_jonathanvegasp_result_1channel_ResultChannel_failure(JNIEnv *env, jclass cls,
                                                              jlong callback_ptr,
                                                              jobject value) {
    ResultNative *instance = new_result_native(env, value, ResultChannelStatusError);
    Callback callback = (Callback) callback_ptr;
    callback(instance);
}
