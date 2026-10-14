package com.ceptestaj.cepte_staj

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Receives text shared into the app (Spotify → Share → Cepte Staj) and
 * hands it to Dart over a small method channel — see
 * lib/core/share_receiver.dart. A share that launches the app is kept until
 * Dart asks for it; one that arrives while running is pushed right away.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pending: Map<String, String?>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cepte_staj/share").apply {
            setMethodCallHandler { call, result ->
                if (call.method == "takePending") {
                    result.success(pending)
                    pending = null
                } else {
                    result.notImplemented()
                }
            }
        }
        pending = sharedTextOf(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val shared = sharedTextOf(intent) ?: return
        channel?.invokeMethod("shared", shared)
    }

    private fun sharedTextOf(intent: Intent?): Map<String, String?>? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") return null
        // Reopened from Recents: the share was already handled back then.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return null
        return mapOf("text" to text, "subject" to intent.getStringExtra(Intent.EXTRA_SUBJECT))
    }
}
