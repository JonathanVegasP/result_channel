package dev.jonathanvegasp.result_channel

import java.nio.ByteBuffer

interface Serializer {
    fun serialize(value: Any?): ByteBuffer

    fun deserialize(value: ByteBuffer): Any?
}
