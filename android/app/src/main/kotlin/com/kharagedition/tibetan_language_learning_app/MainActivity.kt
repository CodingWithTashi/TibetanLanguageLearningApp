package com.kharagedition.tibetan_language_learning_app

import android.content.Context
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The country of the SIM card and of the mobile network. The Shop uses
        // them to open Amazon.in in India and Amazon.com elsewhere. Reading
        // them needs no permission; both are empty without a SIM.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "tibetan_language_learning_app/region"
        ).setMethodCallHandler { call, result ->
            if (call.method != "countries") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val telephony = getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            result.success(
                mapOf(
                    "sim" to (runCatching { telephony?.simCountryIso }.getOrNull() ?: ""),
                    "network" to (runCatching { telephony?.networkCountryIso }.getOrNull() ?: "")
                )
            )
        }
    }
}
