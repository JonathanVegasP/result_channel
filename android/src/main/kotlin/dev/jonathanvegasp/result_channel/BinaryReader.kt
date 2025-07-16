package dev.jonathanvegasp.result_channel

import java.nio.ByteBuffer

class BinaryReader(byteArray: ByteArray) : Reader {
    private val buffer = ByteBuffer.wrap(byteArray)

    private fun readPadding(alignment: Int) {
        val align = alignment - 1

        buffer.position((buffer.position() + align) and align.inv())
    }

    override fun byte(): Byte {
        return buffer.get()
    }

    override fun char(): Char {
        readPadding(Char.SIZE_BYTES)
        return buffer.getChar()
    }

    override fun int(): Int {
        readPadding(Int.SIZE_BYTES)
        return buffer.getInt()
    }

    override fun long(): Long {
        readPadding(Long.SIZE_BYTES)
        return buffer.getLong()
    }

    override fun float(): Float {
        readPadding(Float.SIZE_BYTES)
        return buffer.getFloat()
    }

    override fun double(): Double {
        readPadding(Double.SIZE_BYTES)
        return buffer.getDouble()
    }

    override fun string(size: Int): String {
        return String(byteArray(size), Charsets.UTF_8)
    }

    override fun byteArray(size: Int): ByteArray {
        val bytes = ByteArray(size)
        buffer[bytes]
        return bytes
    }

    override fun intArray(size: Int): IntArray {
        readPadding(Int.SIZE_BYTES)
        val array = IntArray(size)
        val buffer = buffer
        buffer.asIntBuffer()[array]
        buffer.position(buffer.position() + (size shl 2))
        return array
    }

    override fun longArray(size: Int): LongArray {
        readPadding(Long.SIZE_BYTES)
        val array = LongArray(size)
        val buffer = buffer
        buffer.asLongBuffer()[array]
        buffer.position(buffer.position() + (size shl 3))
        return array
    }

    override fun floatArray(size: Int): FloatArray {
        readPadding(Float.SIZE_BYTES)
        val array = FloatArray(size)
        val buffer = buffer
        buffer.asFloatBuffer()[array]
        buffer.position(buffer.position() + (size shl 2))
        return array
    }

    override fun doubleArray(size: Int): DoubleArray {
        readPadding(Double.SIZE_BYTES)
        val array = DoubleArray(size)
        val buffer = buffer
        buffer.asDoubleBuffer()[array]
        buffer.position(buffer.position() + (size shl 3))
        return array
    }
}