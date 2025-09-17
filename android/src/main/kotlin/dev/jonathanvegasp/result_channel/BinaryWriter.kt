package dev.jonathanvegasp.result_channel

import java.nio.ByteBuffer
import java.nio.ByteOrder

class BinaryWriter : Writer {
    companion object {
        private const val INITIAL_SIZE = 1024
        private val ORDER = ByteOrder.nativeOrder()
    }

    private var buffer = ByteBuffer.allocateDirect(INITIAL_SIZE).order(ORDER)
    private var zeroBuffer = ByteArray(8)

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

        buffer.put(zeroBuffer, 0, size)
    }

    override fun byte(value: Byte) {
        growBufferIfNeeded(Byte.SIZE_BYTES)
        buffer.put(value)
    }

    override fun char(value: Char) {
        addPaddingIfNeeded(Char.SIZE_BYTES)
        growBufferIfNeeded(Char.SIZE_BYTES)
        buffer.putChar(value)
    }

    override fun int(value: Int) {
        addPaddingIfNeeded(Int.SIZE_BYTES)
        growBufferIfNeeded(Int.SIZE_BYTES)
        buffer.putInt(value)
    }

    override fun long(value: Long) {
        addPaddingIfNeeded(Long.SIZE_BYTES)
        growBufferIfNeeded(Long.SIZE_BYTES)
        buffer.putLong(value)
    }

    override fun float(value: Float) {
        addPaddingIfNeeded(Float.SIZE_BYTES)
        growBufferIfNeeded(Float.SIZE_BYTES)
        buffer.putFloat(value)
    }

    override fun double(value: Double) {
        addPaddingIfNeeded(Double.SIZE_BYTES)
        growBufferIfNeeded(Double.SIZE_BYTES)
        buffer.putDouble(value)
    }

    override fun byteArray(value: ByteArray) {
        val size = value.size
        growBufferIfNeeded(size)
        buffer.put(value)
    }

    override fun intArray(value: IntArray) {
        val size = value.size shl 2;
        addPaddingIfNeeded(Int.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asIntBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    override fun longArray(value: LongArray) {
        val size = value.size shl 3;
        addPaddingIfNeeded(Long.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asLongBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    override fun floatArray(value: FloatArray) {
        val size = value.size shl 2
        addPaddingIfNeeded(Float.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asFloatBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    override fun doubleArray(value: DoubleArray) {
        val size = value.size shl 3
        addPaddingIfNeeded(Double.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asDoubleBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    override fun toByteBuffer(): ByteBuffer {
        val buffer = buffer
        val offset = buffer.position()
        buffer.position(0)
        buffer.limit(offset)
        return buffer
    }
}