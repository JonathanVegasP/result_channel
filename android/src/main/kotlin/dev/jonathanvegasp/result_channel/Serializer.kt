package dev.jonathanvegasp.result_channel

interface Serializer<T> {
    fun serialize(value: Any?): T

    fun deserialize(value: T): Any?
}