package dev.jonathanvegasp.result_channel

import java.nio.ByteBuffer

object BinarySerializer {
    private const val NULL: Byte = 0x00
    private const val TRUE: Byte = 0x01
    private const val FALSE: Byte = 0x02
    private const val INT: Byte = 0x03
    private const val LONG: Byte = 0x04
    private const val DOUBLE: Byte = 0x05
    private const val STRING: Byte = 0x06
    private const val BYTE_ARRAY: Byte = 0x07
    private const val INT_ARRAY: Byte = 0x08
    private const val LONG_ARRAY: Byte = 0x09
    private const val FLOAT_ARRAY: Byte = 0x0A
    private const val DOUBLE_ARRAY: Byte = 0x0B
    private const val LIST: Byte = 0x0C
    private const val SET: Byte = 0x0D
    private const val MAP: Byte = 0x0E

    private const val MAX_BYTES = 0xFE
    private const val MAX_CHAR = 0xFF
    private const val MAX_CHAR_VALUE = 0xFFFF

    @JvmStatic
    private fun writeSize(writer: BinaryWriter, value: Int) = when {
        value < MAX_BYTES -> writer.putByte(value.toByte())

        value <= MAX_CHAR_VALUE -> {
            writer.putByte(MAX_BYTES.toByte())
            writer.putChar(value.toChar())
        }

        else -> {
            writer.putByte(MAX_CHAR.toByte())
            writer.putInt(value)
        }
    }

    @JvmStatic
    private fun append(writer: BinaryWriter, value: Any?) {
        when (value) {
            null -> writer.putByte(NULL)

            is Boolean -> writer.putByte(if (value) TRUE else FALSE)

            is Byte, is Short, is Int -> {
                writer.putByte(INT)
                value as Number
                writer.putInt(value.toInt())
            }

            is Long -> {
                writer.putByte(LONG)
                writer.putLong(value)
            }

            is Float, is Double -> {
                writer.putByte(DOUBLE)
                value as Number
                writer.putDouble(value.toDouble())
            }

            is CharSequence -> {
                writer.putByte(STRING)
                val byteArray = value.toString().encodeToByteArray()
                writeSize(writer, byteArray.size)
                writer.putByteArray(byteArray)
            }

            is ByteArray -> {
                writer.putByte(BYTE_ARRAY)
                writeSize(writer, value.size)
                writer.putByteArray(value)
            }

            is IntArray -> {
                writer.putByte(INT_ARRAY)
                writeSize(writer, value.size)
                writer.putIntArray(value)
            }

            is LongArray -> {
                writer.putByte(LONG_ARRAY)
                writeSize(writer, value.size)
                writer.putLongArray(value)
            }

            is FloatArray -> {
                writer.putByte(FLOAT_ARRAY)
                writeSize(writer, value.size)
                writer.putFloatArray(value)
            }

            is DoubleArray -> {
                writer.putByte(DOUBLE_ARRAY)
                writeSize(writer, value.size)
                writer.putDoubleArray(value)
            }

            is Array<*> -> {
                writer.putByte(LIST)
                writeSize(writer, value.size)
                value.forEach {
                    append(writer, it)
                }
            }

            is List<*> -> {
                writer.putByte(LIST)
                writeSize(writer, value.size)
                value.forEach {
                    append(writer, it)
                }
            }

            is Set<*> -> {
                writer.putByte(SET)
                writeSize(writer, value.size)
                value.forEach {
                    append(writer, it)
                }
            }

            is Map<*, *> -> {
                writer.putByte(MAP)
                writeSize(writer, value.size)
                value.forEach {
                    append(writer, it.key)
                    append(writer, it.value)
                }
            }
        }
    }

    @JvmStatic
    private fun readSize(reader: BinaryReader): Int {
        val value = reader.getByte().toInt() and 0xFF
        return when {
            value < MAX_BYTES -> value
            value == MAX_BYTES -> reader.getChar().code
            else -> reader.getInt()
        }
    }

    @JvmStatic
    private fun read(reader: BinaryReader): Any? {
        val type = reader.getByte()
        return when (type) {
            NULL -> null
            TRUE -> true
            FALSE -> false
            INT -> reader.getInt()
            LONG -> reader.getLong()
            DOUBLE -> reader.getDouble()
            STRING -> String(reader.getByteArray(readSize(reader)), Charsets.UTF_8)
            BYTE_ARRAY -> reader.getByteArray(readSize(reader))
            INT_ARRAY -> reader.getIntArray(readSize(reader))
            LONG_ARRAY -> reader.getLongArray(readSize(reader))
            FLOAT_ARRAY -> reader.getFloatArray(readSize(reader))
            DOUBLE_ARRAY -> reader.getDoubleArray(readSize(reader))

            LIST -> {
                val size = readSize(reader)
                val array = arrayOfNulls<Any?>(size)
                repeat(size) {
                    array[it] = read(reader)
                }
                array
            }

            SET -> {
                val size = readSize(reader)
                val set = HashSet<Any?>(size)
                repeat(size) {
                    set.add(read(reader))
                }
                set
            }

            MAP -> {
                val size = readSize(reader)
                val map = HashMap<Any?, Any?>(size)
                repeat(size) {
                    map[read(reader)] = read(reader)
                }
                map
            }

            else -> throw IllegalArgumentException("Message corrupted")
        }
    }

    @JvmStatic
    fun serialize(value: Any?): ByteBuffer {
        val writer = BinaryWriter()

        append(writer, value)

        return writer.toByteBuffer()
    }

    @JvmStatic
    fun deserialize(value: ByteBuffer): Any? {
        val reader = BinaryReader(value)

        return read(reader)
    }
}
