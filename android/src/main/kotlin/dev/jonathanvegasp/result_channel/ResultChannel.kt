package dev.jonathanvegasp.result_channel

import androidx.annotation.Keep

class ResultChannel @Keep constructor(private val callbackPtr: Long) {
    companion object {
        @Keep
        @JvmStatic
        external fun success(callbackPtr: Long, value: ByteArray)

        @Keep
        @JvmStatic
        external fun failure(callbackPtr: Long, value: ByteArray)

        var serializer: Serializer<ByteArray> = BinarySerializer()
    }

    fun success(value: Any?) {
        success(callbackPtr, serializer.serialize(value))
    }

    fun failure(value: Any?) {
        failure(callbackPtr, serializer.serialize(value))
    }
}
