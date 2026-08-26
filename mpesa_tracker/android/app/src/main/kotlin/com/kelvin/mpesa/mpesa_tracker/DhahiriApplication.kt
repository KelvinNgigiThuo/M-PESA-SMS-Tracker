package com.kelvin.mpesa.mpesa_tracker

import android.app.Application
import io.flutter.embedding.engine.FlutterEngineGroup

/**
 * Holds one shared FlutterEngineGroup for the app's lifetime. Engines created
 * via a group share the GPU/font/isolate group context instead of each
 * bootstrapping their own from scratch, which is what makes the per-SMS
 * headless recorder engine (TransactionRecorder) cheap enough to spin up
 * repeatedly without a full VM/engine boot each time.
 */
class DhahiriApplication : Application() {
    val engineGroup: FlutterEngineGroup by lazy { FlutterEngineGroup(this) }
}
