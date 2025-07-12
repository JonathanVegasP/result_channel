package dev.jonathanvegasp.result_channel

class BinarySerializer : Serializer<ByteArray> {
    companion object {
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

        private fun writeSize(writer: Writer, value: Int) = when {
            value < MAX_BYTES -> writer.byte(value.toByte())

            value <= MAX_CHAR_VALUE -> {
                writer.byte(MAX_BYTES.toByte())
                writer.char(value.toChar())
            }

            else -> {
                writer.byte(MAX_CHAR.toByte())
                writer.int(value)
            }
        }

        private fun writeByteArray(writer: Writer, value: ByteArray) {
            writeSize(writer, value.size)
            writer.byteArray(value)
        }

        private fun append(writer: Writer, value: Any?) {
            when (value) {
                null -> writer.byte(NULL)

                is Boolean -> writer.byte(if (value) TRUE else FALSE)

                is Byte, is Short, is Int -> {
                    writer.byte(INT)
                    value as Number
                    writer.int(value.toInt())
                }

                is Long -> {
                    writer.byte(LONG)
                    writer.long(value)
                }

                is Float, is Double -> {
                    writer.byte(DOUBLE)
                    value as Number
                    writer.double(value.toDouble())
                }

                is CharSequence -> {
                    writer.byte(STRING)
                    writeByteArray(writer, value.toString().encodeToByteArray())
                }

                is ByteArray -> {
                    writer.byte(BYTE_ARRAY)
                    writeByteArray(writer, value)
                }

                is IntArray -> {
                    writer.byte(INT_ARRAY)
                    writeSize(writer, value.size)
                    writer.intArray(value)
                }

                is LongArray -> {
                    writer.byte(LONG_ARRAY)
                    writeSize(writer, value.size)
                    writer.longArray(value)
                }

                is FloatArray -> {
                    writer.byte(FLOAT_ARRAY)
                    writeSize(writer, value.size)
                    writer.floatArray(value)
                }

                is DoubleArray -> {
                    writer.byte(DOUBLE_ARRAY)
                    writeSize(writer, value.size)
                    writer.doubleArray(value)
                }

                is Array<*> -> {
                    writer.byte(LIST)
                    writeSize(writer, value.size)
                    value.forEach {
                        append(writer, it)
                    }
                }

                is List<*> -> {
                    writer.byte(LIST)
                    writeSize(writer, value.size)
                    value.forEach {
                        append(writer, it)
                    }
                }

                is Set<*> -> {
                    writer.byte(SET)
                    writeSize(writer, value.size)
                    value.forEach {
                        append(writer, it)
                    }
                }

                is Map<*, *> -> {
                    writer.byte(MAP)
                    writeSize(writer, value.size)
                    value.forEach {
                        append(writer, it.key)
                        append(writer, it.value)
                    }
                }
            }
        }

        private fun readSize(reader: Reader): Int {
            val value = reader.byte().toInt() and 0xFF
            return when {
                value < MAX_BYTES -> value
                value == MAX_BYTES -> reader.char().code
                else -> reader.int()
            }
        }

        private fun read(reader: Reader): Any? {
            val type = reader.byte()
            return when (type) {
                NULL -> null
                TRUE -> true
                FALSE -> false
                INT -> reader.int()
                LONG -> reader.long()
                DOUBLE -> reader.double()
                STRING -> reader.string(readSize(reader))
                BYTE_ARRAY -> reader.byteArray(readSize(reader))
                INT_ARRAY -> reader.intArray(readSize(reader))
                LONG_ARRAY -> reader.longArray(readSize(reader))
                FLOAT_ARRAY -> reader.floatArray(readSize(reader))
                DOUBLE_ARRAY -> reader.doubleArray(readSize(reader))
                LIST -> {
                    val size = readSize(reader)
                    val array = ArrayList<Any?>(size)
                    repeat(size) {
                        array.add(read(reader))
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
    }

    override fun serialize(value: Any?): ByteArray {
        val writer = BinaryWriter()

        append(writer, value)

        return writer.toByteArray()
    }


    override fun deserialize(value: ByteArray): Any? {
        val reader = BinaryReader(value)

        return read(reader)
    }
}