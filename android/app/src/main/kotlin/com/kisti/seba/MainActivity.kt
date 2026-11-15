package com.kisti.seba

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configureDisplayFor60Fps()
    }

    private fun configureDisplayFor60Fps() {
        try {
            window?.setFlags(
                WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
                WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val window = window ?: return
                val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    display
                } else {
                    @Suppress("DEPRECATION")
                    windowManager.defaultDisplay
                }

                val modes = display?.supportedModes ?: return
                // Default to at least 60Hz or optimal refresh rate
                var targetMode = modes.firstOrNull { it.refreshRate in 59.0f..61.0f }
                if (targetMode == null) {
                    targetMode = modes.maxByOrNull { it.refreshRate }
                }

                if (targetMode != null) {
                    val params = window.attributes
                    params.preferredDisplayModeId = targetMode.modeId
                    window.attributes = params
                }
            }
        } catch (_: Exception) {
            // Safe fallback
        }
    }
}
