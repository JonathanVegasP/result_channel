package dev.jonathanvegasp.result_channel

import java.nio.ByteBuffer
import java.nio.ByteOrder

internal class BinaryWriter {
    companion object {
        private const val INITIAL_SIZE = 1024
        private val ORDER = ByteOrder.nativeOrder()
        private val ZERO_BUFFER = ByteArray(8)
    }

    private var buffer = ByteBuffer.allocateDirect(INITIAL_SIZE).order(ORDER)


    private fun growBufferIfNeeded(size: Int) {
        val buffer = buffer
        val offset = buffer.position()
        val requiredSize = offset + size
        val capacity = buffer.capacity()

        if (capacity >= requiredSize) return

        var newCapacity = capacity shl 1

        while (newCapacity < requiredSize) {
            newCapacity = newCapacity shl 1
        }

        val newBuffer = ByteBuffer.allocateDirect(newCapacity).order(ORDER)

        buffer.position(0)
        buffer.limit(offset)
        newBuffer.put(buffer)

        this.buffer = newBuffer
    }

    private fun addPaddingIfNeeded(alignment: Int) {
        val buffer = buffer
        val mask = alignment - 1
        val remainder = buffer.position() and mask

        if (remainder == 0) return

        val size = alignment - remainder

        growBufferIfNeeded(size)

        buffer.put(ZERO_BUFFER, 0, size)
    }

    fun putByte(value: Byte) {
        growBufferIfNeeded(Byte.SIZE_BYTES)
        buffer.put(value)
    }

    fun putChar(value: Char) {
        addPaddingIfNeeded(Char.SIZE_BYTES)
        growBufferIfNeeded(Char.SIZE_BYTES)
        buffer.putChar(value)
    }

    fun putInt(value: Int) {
        addPaddingIfNeeded(Int.SIZE_BYTES)
        growBufferIfNeeded(Int.SIZE_BYTES)
        buffer.putInt(value)
    }

    fun putLong(value: Long) {
        addPaddingIfNeeded(Long.SIZE_BYTES)
        growBufferIfNeeded(Long.SIZE_BYTES)
        buffer.putLong(value)
    }

    fun putDouble(value: Double) {
        addPaddingIfNeeded(Double.SIZE_BYTES)
        growBufferIfNeeded(Double.SIZE_BYTES)
        buffer.putDouble(value)
    }

    fun putByteArray(value: ByteArray) {
        val size = value.size
        growBufferIfNeeded(size)
        buffer.put(value)
    }

    fun putIntArray(value: IntArray) {
        val size = value.size shl 2;
        addPaddingIfNeeded(Int.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asIntBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    fun putLongArray(value: LongArray) {
        val size = value.size shl 3;
        addPaddingIfNeeded(Long.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asLongBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    fun putFloatArray(value: FloatArray) {
        val size = value.size shl 2
        addPaddingIfNeeded(Float.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asFloatBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    fun putDoubleArray(value: DoubleArray) {
        val size = value.size shl 3
        addPaddingIfNeeded(Double.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asDoubleBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    fun toByteBuffer(): ByteBuffer {
        val buffer = buffer
        val offset = buffer.position()
        buffer.position(0)
        buffer.limit(offset)
        return buffer
    }
}