package dev.jonathanvegasp.result_channel

import io.flutter.embedding.engine.plugins.FlutterPlugin

class ResultChannelPlugin : FlutterPlugin {
    companion object {
        private const val NAME = "result_channel";

        init {
            System.loadLibrary(NAME)
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
