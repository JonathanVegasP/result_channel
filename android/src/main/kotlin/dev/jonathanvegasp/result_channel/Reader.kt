package dev.jonathanvegasp.result_channel

interface Reader {
    fun byte(): Byte
    fun char(): Char
    fun int(): Int
    fun long(): Long
    fun float(): Float
    fun double(): Double
    fun string(size: Int): String
    fun byteArray(size: Int): ByteArray
    fun intArray(size: Int): IntArray
    fun longArray(size: Int): LongArray
    fun floatArray(size: Int): FloatArray
    fun doubleArray(size: Int): DoubleArray
}
