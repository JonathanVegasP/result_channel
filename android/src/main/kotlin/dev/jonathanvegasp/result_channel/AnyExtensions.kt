package dev.jonathanvegasp.result_channel

fun Any?.toLong(): Long {
    if (this is Int) {
        return this.toLong();
    }

    return this as Long
}
