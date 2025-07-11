package dev.jonathanvegasp.result_channel

import java.nio.ByteBuffer
import java.nio.ByteOrder

class BinaryWriter : Writer {
    companion object {
        private const val INITIAL_SIZE = 1024
        private val ORDER = ByteOrder.nativeOrder()
    }

    private var buffer = ByteBuffer.allocateDirect(INITIAL_SIZE).order(ORDER)

    private fun growBufferIfNeeded(size: Int) {
        val buffer = buffer
        val offset = buffer.position()
        val requiredSize = offset + size
        val capacity = buffer.capacity()

        if (requiredSize <= capacity) return

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
        val remainder = buffer.position() % alignment

        if (remainder == 0) return

        val size = alignment - remainder

        growBufferIfNeeded(size)

        repeat(size) {
            buffer.put(0x00)
        }
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
        val size = value.size * Int.SIZE_BYTES;
        addPaddingIfNeeded(Int.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asIntBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    override fun longArray(value: LongArray) {
        val size = value.size * Long.SIZE_BYTES;
        addPaddingIfNeeded(Long.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asLongBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    override fun floatArray(value: FloatArray) {
        val size = value.size * Float.SIZE_BYTES
        addPaddingIfNeeded(Float.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asFloatBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    override fun doubleArray(value: DoubleArray) {
        val size = Double.SIZE_BYTES * value.size
        addPaddingIfNeeded(Double.SIZE_BYTES)
        growBufferIfNeeded(size)
        val buffer = buffer
        buffer.asDoubleBuffer().put(value)
        buffer.position(buffer.position() + size)
    }

    override fun toByteArray(): ByteArray {
        val buffer = buffer
        val offset = buffer.position()
        buffer.position(0)
        buffer.limit(offset)
        val array = ByteArray(offset)
        buffer[array]
        return array
    }
}