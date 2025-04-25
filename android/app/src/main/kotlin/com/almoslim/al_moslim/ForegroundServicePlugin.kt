package com.almoslim.al_moslim

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.LayoutInflater
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class ForegroundServicePlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var overlayPermissionResult: Result? = null
    private val OVERLAY_PERMISSION_REQUEST_CODE = 1234

    // Views for notifications
    private var prayerNotificationView: FrameLayout? = null
    private var adkarNotificationView: FrameLayout? = null
    private var ayahNotificationView: FrameLayout? = null

    // Window manager for displaying views
    private var windowManager: WindowManager? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.almoslim/foreground_service")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                initialize()
                result.success(null)
            }
            "requestOverlayPermission" -> {
                requestOverlayPermission(result)
            }
            "hasOverlayPermission" -> {
                result.success(hasOverlayPermission())
            }
            "showPrayerNotification" -> {
                val title = call.argument<String>("title") ?: ""
                val message = call.argument<String>("message") ?: ""
                showPrayerNotification(title, message)
                result.success(null)
            }
            "showAdkarNotification" -> {
                val title = call.argument<String>("title") ?: ""
                val message = call.argument<String>("message") ?: ""
                showAdkarNotification(title, message)
                result.success(null)
            }
            "showAyahNotification" -> {
                val title = call.argument<String>("title") ?: ""
                val message = call.argument<String>("message") ?: ""
                showAyahNotification(title, message)
                result.success(null)
            }
            "dismissAllNotifications" -> {
                dismissAllNotifications()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize() {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    private fun requestOverlayPermission(result: Result) {
        if (hasOverlayPermission()) {
            result.success(true)
            return
        }

        activity?.let {
            overlayPermissionResult = result
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${it.packageName}")
            )
            it.startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST_CODE)
        } ?: run {
            result.error("ACTIVITY_NULL", "Activity is null", null)
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    private fun showPrayerNotification(title: String, message: String) {
        if (!hasOverlayPermission()) {
            return
        }

        activity?.runOnUiThread {
            // Remove any existing prayer notification
            dismissPrayerNotification()

            // Create a new prayer notification view
            val inflater = LayoutInflater.from(context)
            prayerNotificationView = inflater.inflate(R.layout.prayer_notification, null) as FrameLayout

            // Set the title and message
            prayerNotificationView?.findViewById<TextView>(R.id.notification_title)?.text = title
            prayerNotificationView?.findViewById<TextView>(R.id.notification_message)?.text = message

            // Set up the buttons
            prayerNotificationView?.findViewById<Button>(R.id.stop_adhan_button)?.setOnClickListener {
                // Send event to Flutter to stop adhan
                channel.invokeMethod("onStopAdhan", null)
            }

            prayerNotificationView?.findViewById<Button>(R.id.dismiss_button)?.setOnClickListener {
                dismissPrayerNotification()
            }

            // Add the view to the window
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                android.graphics.PixelFormat.TRANSLUCENT
            )

            windowManager?.addView(prayerNotificationView, params)
        }
    }

    private fun showAdkarNotification(title: String, message: String) {
        if (!hasOverlayPermission()) {
            return
        }

        activity?.runOnUiThread {
            // Remove any existing adkar notification
            dismissAdkarNotification()

            // Create a new adkar notification view
            val inflater = LayoutInflater.from(context)
            adkarNotificationView = inflater.inflate(R.layout.adkar_notification, null) as FrameLayout

            // Set the title and message
            adkarNotificationView?.findViewById<TextView>(R.id.notification_title)?.text = title
            adkarNotificationView?.findViewById<TextView>(R.id.notification_message)?.text = message

            // Set up the dismiss button
            adkarNotificationView?.findViewById<Button>(R.id.dismiss_button)?.setOnClickListener {
                dismissAdkarNotification()
            }

            // Add the view to the window
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                android.graphics.PixelFormat.TRANSLUCENT
            )

            windowManager?.addView(adkarNotificationView, params)
        }
    }

    private fun showAyahNotification(title: String, message: String) {
        if (!hasOverlayPermission()) {
            return
        }

        activity?.runOnUiThread {
            // Remove any existing ayah notification
            dismissAyahNotification()

            // Create a new ayah notification view
            val inflater = LayoutInflater.from(context)
            ayahNotificationView = inflater.inflate(R.layout.ayah_notification, null) as FrameLayout

            // Set the title and message
            ayahNotificationView?.findViewById<TextView>(R.id.notification_title)?.text = title
            ayahNotificationView?.findViewById<TextView>(R.id.notification_message)?.text = message

            // Set up the dismiss button
            ayahNotificationView?.findViewById<Button>(R.id.dismiss_button)?.setOnClickListener {
                dismissAyahNotification()
            }

            // Add the view to the window
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                android.graphics.PixelFormat.TRANSLUCENT
            )

            windowManager?.addView(ayahNotificationView, params)
        }
    }

    private fun dismissPrayerNotification() {
        activity?.runOnUiThread {
            prayerNotificationView?.let {
                windowManager?.removeView(it)
                prayerNotificationView = null
            }
        }
    }

    private fun dismissAdkarNotification() {
        activity?.runOnUiThread {
            adkarNotificationView?.let {
                windowManager?.removeView(it)
                adkarNotificationView = null
            }
        }
    }

    private fun dismissAyahNotification() {
        activity?.runOnUiThread {
            ayahNotificationView?.let {
                windowManager?.removeView(it)
                ayahNotificationView = null
            }
        }
    }

    private fun dismissAllNotifications() {
        dismissPrayerNotification()
        dismissAdkarNotification()
        dismissAyahNotification()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == OVERLAY_PERMISSION_REQUEST_CODE) {
            overlayPermissionResult?.success(hasOverlayPermission())
            overlayPermissionResult = null
            return true
        }
        return false
    }
}
