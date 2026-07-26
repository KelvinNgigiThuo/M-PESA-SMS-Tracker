package com.kelvin.mpesa.mpesa_tracker

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.Manifest
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.kelvin.mpesa/overlay"
    }

    private var channel: MethodChannel? = null
    private var pendingData: Map<String, Any>? = null
    private var flutterReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val missingPermissions = mutableListOf<String>()
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS)
            != PackageManager.PERMISSION_GRANTED) {
            missingPermissions.add(Manifest.permission.RECEIVE_SMS)
            missingPermissions.add(Manifest.permission.READ_SMS)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED) {
            missingPermissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }
        if (missingPermissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                missingPermissions.toTypedArray(),
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

        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
            try {
                startActivity(
                    Intent(
                        Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                        Uri.parse("package:$packageName")
                    )
                )
            } catch (e: ActivityNotFoundException) {
                Log.w("MainActivity", "Battery optimization exemption screen unavailable", e)
            }
        }

        if (intent?.getBooleanExtra("fromBubble", false) == true) {
            pendingData = extractTransactionData(intent)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL
        )
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "flutterReady" -> {
                    flutterReady = true
                    Log.d("MainActivity", "Flutter is ready")
                    pendingData?.let {
                        sendToFlutter(it)
                        pendingData = null
                    }
                    result.success(null)
                }
                "openBackgroundSettings" -> {
                    openBackgroundSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Best-effort: open the OEM's background/autostart management screen.
     * ColorOS (Oppo/Realme) hides this behind a vendor-specific activity that
     * varies by version — try known component names, then fall back to the
     * generic app-details settings page so the user can find it manually.
     */
    private fun openBackgroundSettings() {
        val manufacturer = Build.MANUFACTURER.lowercase()
        if (manufacturer.contains("oppo") || manufacturer.contains("realme")) {
            val candidates = listOf(
                ComponentName(
                    "com.coloros.safecenter",
                    "com.coloros.safecenter.startupapp.StartupAppListActivity"
                ),
                ComponentName(
                    "com.coloros.safecenter",
                    "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                ),
                ComponentName(
                    "com.oppo.safe",
                    "com.oppo.safe.permission.startup.StartupAppListActivity"
                )
            )
            for (component in candidates) {
                try {
                    startActivity(Intent().apply {
                        this.component = component
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    })
                    return
                } catch (e: ActivityNotFoundException) {
                    // Try the next candidate
                }
            }
        }

        try {
            startActivity(
                Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.parse("package:$packageName")
                )
            )
        } catch (e: ActivityNotFoundException) {
            Log.w("MainActivity", "No settings screen available to open", e)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("fromBubble", false)) {
            val data = extractTransactionData(intent)
            if (flutterReady) sendToFlutter(data)
            else pendingData = data
        }
    }

    fun sendToFlutter(data: Map<String, Any>) {
        runOnUiThread {
            channel?.invokeMethod("showTagCard", data)
        }
    }

    private fun extractTransactionData(intent: Intent): Map<String, Any> {
        return mapOf(
            "amount"    to intent.getDoubleExtra("amount", 0.0),
            "recipient" to (intent.getStringExtra("recipient") ?: ""),
            "direction" to (intent.getStringExtra("direction") ?: "out"),
            "txCode"    to (intent.getStringExtra("txCode") ?: ""),
            "balance"   to intent.getDoubleExtra("balance", 0.0),
            "txCost"    to intent.getDoubleExtra("txCost", 0.0)
        )
    }
}
