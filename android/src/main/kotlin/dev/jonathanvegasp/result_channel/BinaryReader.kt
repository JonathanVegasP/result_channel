package dev.jonathanvegasp.result_channel

import java.nio.ByteBuffer
import java.nio.ByteOrder

internal class BinaryReader(buffer: ByteBuffer) {
    private val buffer = buffer.order(ByteOrder.nativeOrder())

    private fun readPadding(alignment: Int) {
        val align = alignment - 1

        buffer.position((buffer.position() + align) and align.inv())
    }

    fun getByte(): Byte {
        return buffer.get()
    }

    fun getChar(): Char {
        readPadding(Char.SIZE_BYTES)
        return buffer.getChar()
    }

    fun getInt(): Int {
        readPadding(Int.SIZE_BYTES)
        return buffer.getInt()
    }

    fun getLong(): Long {
        readPadding(Long.SIZE_BYTES)
        return buffer.getLong()
    }

    fun getDouble(): Double {
        readPadding(Double.SIZE_BYTES)
        return buffer.getDouble()
    }

    fun getByteArray(size: Int): ByteArray {
        val bytes = ByteArray(size)
        buffer[bytes]
        return bytes
    }

    fun getIntArray(size: Int): IntArray {
        readPadding(Int.SIZE_BYTES)
        val array = IntArray(size)
        val buffer = buffer
        buffer.asIntBuffer()[array]
        buffer.position(buffer.position() + (size shl 2))
        return array
    }

    fun getLongArray(size: Int): LongArray {
        readPadding(Long.SIZE_BYTES)
        val array = LongArray(size)
        val buffer = buffer
        buffer.asLongBuffer()[array]
        buffer.position(buffer.position() + (size shl 3))
        return array
    }

    fun getFloatArray(size: Int): FloatArray {
        readPadding(Float.SIZE_BYTES)
        val array = FloatArray(size)
        val buffer = buffer
        buffer.asFloatBuffer()[array]
        buffer.position(buffer.position() + (size shl 2))
        return array
    }

    fun getDoubleArray(size: Int): DoubleArray {
        readPadding(Double.SIZE_BYTES)
        val array = DoubleArray(size)
        val buffer = buffer
        buffer.asDoubleBuffer()[array]
        buffer.position(buffer.position() + (size shl 3))
        return array
    }
}