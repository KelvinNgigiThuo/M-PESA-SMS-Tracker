package com.kelvin.mpesa.mpesa_tracker

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class TagCardActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.kelvin.mpesa/overlay"
    }

    private var channel: MethodChannel? = null

    // TextureView renders transparently unlike SurfaceView
    override fun getRenderMode(): RenderMode = RenderMode.texture

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        channel?.setMethodCallHandler { call, result ->
            if (call.method == "flutterReady") {
                val data = extractData()
                channel?.invokeMethod("showTagCard", data)
                result.success(null)
            } else if (call.method == "closeTagCard") {
                finish()
                result.success(null)
            }
        }
    }

    private fun extractData(): Map<String, Any> {
        return mapOf(
            "amount"    to (intent.getDoubleExtra("amount", 0.0)),
            "recipient" to (intent.getStringExtra("recipient") ?: ""),
            "direction" to (intent.getStringExtra("direction") ?: "out"),
            "txCode"    to (intent.getStringExtra("txCode") ?: ""),
            "balance"   to (intent.getDoubleExtra("balance", 0.0)),
            "txCost"    to (intent.getDoubleExtra("txCost", 0.0))
        )
    }

    override fun onBackPressed() {
        channel?.invokeMethod("dismissTagCard", null)
        super.onBackPressed()
    }
}