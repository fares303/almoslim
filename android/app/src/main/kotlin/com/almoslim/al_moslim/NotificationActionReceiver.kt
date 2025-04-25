package com.almoslim.al_moslim

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel

class NotificationActionReceiver : BroadcastReceiver() {
    companion object {
        var methodChannel: MethodChannel? = null
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "STOP_ADHAN" -> {
                // Send message to Flutter to stop adhan
                methodChannel?.invokeMethod("stopAdhan", null)
            }
        }
    }
}
