package io.github.amansikarwar.freedium_mobile

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private var backupResult: MethodChannel.Result? = null
    private val backupRequestCode = 4102

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "freedium/bookmark_backup")
            .setMethodCallHandler { call, result ->
                if (call.method != "openBackup") {
                    result.notImplemented()
                } else if (backupResult != null) {
                    result.error("busy", "A backup picker is already open", null)
                } else {
                    backupResult = result
                    try {
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "*/*"
                            putExtra(Intent.EXTRA_MIME_TYPES,
                                arrayOf("application/json", "text/plain", "application/octet-stream"))
                        }
                        startActivityForResult(intent, backupRequestCode)
                    } catch (error: Exception) {
                        backupResult = null
                        result.error("picker_failed", "Could not open the backup picker", null)
                    }
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != backupRequestCode) return
        val result = backupResult ?: return
        backupResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        thread(name = "bookmark-backup") {
            try {
                // ponytail: 1 MiB backups; raise with the library capacity if needed.
                val maxBytes = 1024 * 1024
                val bytes = ByteArray(maxBytes + 1)
                var size = 0
                val input = contentResolver.openInputStream(uri)
                    ?: throw IllegalStateException("Backup could not be opened")
                input.use {
                    while (size < bytes.size) {
                        val count = it.read(bytes, size, bytes.size - size)
                        if (count < 0) break
                        size += count
                    }
                }
                require(size <= maxBytes) { "Backup is too large" }
                val backup = Charsets.UTF_8.newDecoder()
                    .decode(ByteBuffer.wrap(bytes, 0, size)).toString()
                runOnUiThread { result.success(backup) }
            } catch (error: Exception) {
                runOnUiThread { result.error("read_failed", "Could not read this backup file", null) }
            }
        }
    }
}
