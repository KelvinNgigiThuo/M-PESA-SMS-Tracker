package com.kelvin.mpesa.mpesa_tracker

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Spins up a UI-less Flutter engine (mirroring the same pattern used for
 * the tag card's own `tagCardMain` engine) that runs `recordTransactionMain`
 * just long enough to write one transaction row as untagged, then shuts
 * down. Called from OverlayService for every parsed SMS, so a record
 * exists before the bubble is ever shown — independent of whether it's
 * tapped, replaced by a newer message, or times out unseen.
 *
 * Must be called from the main thread (FlutterEngine requires it).
 */
object TransactionRecorder {
    private const val TAG = "TransactionRecorder"
    private const val CHANNEL = "com.kelvin.mpesa/record"
    private const val TIMEOUT_MS = 5_000L

    fun record(
        context: Context,
        amount: Double,
        recipient: String,
        direction: String,
        txCode: String,
        balance: Double
    ) {
        try {
            val appContext = context.applicationContext
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(appContext)
            loader.ensureInitializationComplete(appContext, null)

            val engine = FlutterEngine(appContext)
            val handler = Handler(Looper.getMainLooper())
            var finished = false

            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)

            val cleanup = Runnable {
                if (!finished) {
                    finished = true
                    try {
                        engine.destroy()
                    } catch (e: Exception) {
                        Log.w(TAG, "Engine destroy failed", e)
                    }
                }
            }
            // Safety net in case the Dart side never responds.
            handler.postDelayed(cleanup, TIMEOUT_MS)

            channel.setMethodCallHandler { call, result ->
                if (call.method == "ready") {
                    val data = mapOf(
                        "amount" to amount,
                        "recipient" to recipient,
                        "direction" to direction,
                        "txCode" to txCode,
                        "balance" to balance
                    )
                    channel.invokeMethod("recordUntagged", data, object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            handler.removeCallbacks(cleanup)
                            cleanup.run()
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?
                        ) {
                            Log.w(TAG, "recordUntagged failed: $errorMessage")
                            handler.removeCallbacks(cleanup)
                            cleanup.run()
                        }

                        override fun notImplemented() {
                            handler.removeCallbacks(cleanup)
                            cleanup.run()
                        }
                    })
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }

            val entrypoint = DartExecutor.DartEntrypoint(
                loader.findAppBundlePath(),
                "recordTransactionMain"
            )
            engine.dartExecutor.executeDartEntrypoint(entrypoint)
        } catch (e: Exception) {
            // Degrades gracefully: the tag-card-open safety net
            // (recordUntaggedIfNeeded in overlay_channel.dart) still
            // catches this transaction if the bubble is eventually tapped.
            Log.e(TAG, "Failed to record transaction headlessly", e)
        }
    }
}
