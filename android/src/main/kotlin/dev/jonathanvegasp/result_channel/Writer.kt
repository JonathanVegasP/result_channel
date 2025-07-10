package dev.jonathanvegasp.result_channel

interface Writer {
    fun byte(value: Byte)

    fun char(value: Char)

    fun int(value: Int)

    fun long(value: Long)

    fun float(value: Float)

    fun double(value: Double)

    fun byteArray(value: ByteArray)

    fun intArray(value: IntArray)

    fun longArray(value: LongArray)

    fun floatArray(value: FloatArray)

    fun doubleArray(value: DoubleArray)

    fun toByteArray(): ByteArray
}