package dev.jonathanvegasp.result_channel_example

import android.annotation.SuppressLint
import android.app.AlertDialog
import android.content.Context
import android.os.Build
import androidx.annotation.Keep
import dev.jonathanvegasp.result_channel.BinarySerializer
import dev.jonathanvegasp.result_channel.ResultChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.nio.ByteBuffer
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

class MainActivity : FlutterActivity() {
    companion object {
        @SuppressLint("StaticFieldLeak")
        private var CONTEXT: Context? = null

        @JvmStatic
        @Keep
        fun openAlertDialogImmediate() {
            AlertDialog.Builder(CONTEXT!!)
                .setTitle("Alert")
                .setMessage("This is an alert")
                .setPositiveButton("Close") { dialog, _ ->
                    dialog.dismiss()
                }.show()
        }

        @JvmStatic
        @Keep
        fun openAlertDialogImmediateWithArgs(byteBuffer: ByteBuffer) {
            val data = BinarySerializer.deserialize(byteBuffer) as List<Any?>
            val title = data[0] as String
            val message = data[1] as String
            val buttonTitle = data[2] as String
            AlertDialog.Builder(CONTEXT!!)
                .setTitle(title)
                .setMessage(message)
                .setPositiveButton(buttonTitle) { dialog, _ ->
                    dialog.dismiss()
                }.show()
        }

        @JvmStatic
        @Keep
        fun getPlatformVersion(): ByteBuffer {
            return BinarySerializer.serialize("Android ${Build.VERSION.RELEASE}")
        }

        @JvmStatic
        @Keep
        fun getFormattedDate(buffer: ByteBuffer): ByteBuffer {
            val format = BinarySerializer.deserialize(buffer) as String

            val calendar = Calendar.getInstance(Locale.getDefault())

            val formatter = SimpleDateFormat(format, Locale.getDefault())

            return BinarySerializer.serialize(formatter.format(calendar.time))
        }

        @JvmStatic
        @Keep
        fun openAlertDialogAsync(resultChannel: ResultChannel) {
            AlertDialog.Builder(CONTEXT!!)
                .setTitle("Alert")
                .setMessage("Is this awesome?")
                .setPositiveButton("Yes") { dialog, _ ->
                    dialog.dismiss()
                    resultChannel.success(true)
                }.setNegativeButton("No") { dialog, _ ->
                    dialog.dismiss()
                    resultChannel.success(false)
                }.show()
        }

        @JvmStatic
        @Keep
        fun openAlertDialogAsyncWithArgs(resultChannel: ResultChannel, buffer: ByteBuffer) {
            val data = BinarySerializer.deserialize(buffer) as List<Any?>
            val title = data[0] as String
            val message = data[1] as String
            val positiveButtonTitle = data[2] as String
            val negativeButtonTitle = data[3] as String

            AlertDialog.Builder(CONTEXT!!)
                .setTitle(title)
                .setMessage(message)
                .setPositiveButton(positiveButtonTitle) { dialog, _ ->
                    dialog.dismiss()
                    resultChannel.success(true)
                }.setNegativeButton(negativeButtonTitle) { dialog, _ ->
                    dialog.dismiss()
                    resultChannel.success(false)
                }.show()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        CONTEXT = this
        super.configureFlutterEngine(flutterEngine)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        CONTEXT = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
