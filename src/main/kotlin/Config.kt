package dev.mtctx.ricer

data class Config(
    val name: String,
    val description: String,
    val configs: List<File>,
) {
    data class File(
        val path: String,
        val symlinkLocation: String,
        val deleteFiles: List<DeleteLocation>,
        val content: List<String>,
    ) {
        enum class DeleteLocation {
            TARGET_PARENT_LOCATION,
            TARGET_LOCATION,
            SYMLINK_PARENT_LOCATION,
            SYMLINK_LOCATION,
        }
    }
}