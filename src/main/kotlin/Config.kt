package dev.mtctx.ricer

data class Config(
    val name: String,
    val description: String,
    val configs: List<File>,
) {
    data class File(
        val path: String,
        val symlinkLocation: String,
        val content: String,
        val actions: List<String>
    )
}