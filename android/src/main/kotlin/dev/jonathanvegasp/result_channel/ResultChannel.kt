package dev.jonathanvegasp.result_channel

import androidx.annotation.Keep
import java.nio.ByteBuffer

class ResultChannel @Keep constructor(private val callbackPtr: Long) {
    companion object {
        @Keep
        @JvmStatic
        external fun success(callbackPtr: Long, value: ByteBuffer)

        @Keep
        @JvmStatic
        external fun failure(callbackPtr: Long, value: ByteBuffer)
    }

    fun success(value: Any?) {
        success(callbackPtr, BinarySerializer.serialize(value))
    }

    fun failure(value: Any?) {
        failure(callbackPtr, BinarySerializer.serialize(value))
    }
}
