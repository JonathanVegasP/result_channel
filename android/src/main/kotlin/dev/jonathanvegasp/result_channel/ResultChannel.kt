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

        @JvmStatic
        fun serialize(value: Any?) : ByteBuffer {
            return BinarySerializer().serialize(value)
        }

        @JvmStatic
        fun deserialize(value: ByteBuffer) : Any? {
            return BinarySerializer().deserialize(value)
        }
    }

    fun success(value: Any?) {
        val serializer = BinarySerializer()
        success(callbackPtr, serializer.serialize(value))
    }

    fun failure(value: Any?) {
        val serializer = BinarySerializer()
        failure(callbackPtr, serializer.serialize(value))
    }
}
