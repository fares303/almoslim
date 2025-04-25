package com.almoslim.al_moslim

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class NotificationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private lateinit var notificationHelper: NotificationHelper
    
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.almoslim/notifications")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        notificationHelper = NotificationHelper(context)
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "showPrayerNotification" -> {
                val title = call.argument<String>("title") ?: ""
                val message = call.argument<String>("message") ?: ""
                notificationHelper.showPrayerNotification(title, message, channel)
                result.success(null)
            }
            "showAdkarNotification" -> {
                val title = call.argument<String>("title") ?: ""
                val message = call.argument<String>("message") ?: ""
                notificationHelper.showAdkarNotification(title, message)
                result.success(null)
            }
            "showAyahNotification" -> {
                val title = call.argument<String>("title") ?: ""
                val message = call.argument<String>("message") ?: ""
                notificationHelper.showAyahNotification(title, message)
                result.success(null)
            }
            "cancelAllNotifications" -> {
                notificationHelper.cancelAllNotifications()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
    
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    
    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
    
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    
    override fun onDetachedFromActivity() {
        activity = null
    }
}
