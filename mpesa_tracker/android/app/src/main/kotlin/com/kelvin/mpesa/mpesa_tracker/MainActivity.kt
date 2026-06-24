package com.kelvin.mpesa.mpesa_tracker

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.Manifest

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.kelvin.mpesa/overlay"
    }

    private var channel: MethodChannel? = null
    private var pendingData: Map<String, Any>? = null
    private var flutterReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.RECEIVE_SMS,
                    Manifest.permission.READ_SMS
                ),
                1001
            )
        }

        if (!Settings.canDrawOverlays(this)) {
            startActivity(
                Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                )
            )
        }

        // App was launched by bubble tap
        if (intent?.getBooleanExtra("fromBubble", false) == true) {
            pendingData = extractTransactionData(intent)
            Log.d("MainActivity", "Launched from bubble, data pending Flutter ready")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel?.setMethodCallHandler { call, result ->
            if (call.method == "flutterReady") {
                flutterReady = true
                Log.d("MainActivity", "Flutter is ready")
                // Send any data that arrived before Flutter was ready
                pendingData?.let {
                    sendToFlutter(it)
                    pendingData = null
                }
                result.success(null)
            }
        }
    }

    // Called when app is already running and bubble brings it to foreground
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        if (intent.getBooleanExtra("fromBubble", false)) {
            val data = extractTransactionData(intent)
            Log.d("MainActivity", "onNewIntent from bubble")
            if (flutterReady) {
                sendToFlutter(data)
            } else {
                pendingData = data
            }
        }
    }

    fun sendToFlutter(data: Map<String, Any>) {
        Log.d("MainActivity", "Sending to Flutter: $data")
        runOnUiThread {
            channel?.invokeMethod("showTagCard", data)
        }
    }

    private fun extractTransactionData(intent: Intent): Map<String, Any> {
        return mapOf(
            "amount" to (intent.getDoubleExtra("amount", 0.0)),
            "recipient" to (intent.getStringExtra("recipient") ?: ""),
            "direction" to (intent.getStringExtra("direction") ?: "out"),
            "txCode" to (intent.getStringExtra("txCode") ?: ""),
            "balance" to (intent.getDoubleExtra("balance", 0.0)),
            "txCost" to (intent.getDoubleExtra("txCost", 0.0))
        )
    }
}