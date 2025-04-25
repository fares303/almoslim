package com.almoslim.al_moslim

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.MethodChannel

class NotificationHelper(private val context: Context) {
    private val notificationManager: NotificationManagerCompat = NotificationManagerCompat.from(context)
    
    companion object {
        const val PRAYER_CHANNEL_ID = "prayer_channel"
        const val ADKAR_CHANNEL_ID = "adkar_channel"
        const val AYAH_CHANNEL_ID = "ayah_channel"
        
        const val PRAYER_NOTIFICATION_ID = 1
        const val ADKAR_NOTIFICATION_ID = 2
        const val AYAH_NOTIFICATION_ID = 3
    }
    
    init {
        createNotificationChannels()
    }
    
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Prayer channel
            val prayerChannel = NotificationChannel(
                PRAYER_CHANNEL_ID,
                "Prayer Times",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for prayer times"
                enableLights(true)
                lightColor = Color.GREEN
                enableVibration(true)
                
                // Set adhan sound
                val soundUri = Uri.parse("android.resource://${context.packageName}/raw/adhan")
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                setSound(soundUri, audioAttributes)
            }
            
            // Adkar channel
            val adkarChannel = NotificationChannel(
                ADKAR_CHANNEL_ID,
                "Adkar",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for adkar"
                enableLights(true)
                lightColor = Color.BLUE
                enableVibration(true)
            }
            
            // Ayah channel
            val ayahChannel = NotificationChannel(
                AYAH_CHANNEL_ID,
                "Daily Ayah",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for daily ayah"
                enableLights(true)
                lightColor = Color.MAGENTA
                enableVibration(true)
            }
            
            // Register the channels
            notificationManager.createNotificationChannel(prayerChannel)
            notificationManager.createNotificationChannel(adkarChannel)
            notificationManager.createNotificationChannel(ayahChannel)
        }
    }
    
    fun showPrayerNotification(title: String, message: String, methodChannel: MethodChannel) {
        // Create an intent to open the app when notification is tapped
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.putExtra("notification_type", "prayer")
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Create stop adhan action
        val stopAdhanIntent = Intent(context, NotificationActionReceiver::class.java).apply {
            action = "STOP_ADHAN"
        }
        val stopAdhanPendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            stopAdhanIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build the notification
        val builder = NotificationCompat.Builder(context, PRAYER_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setColor(Color.GREEN)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .addAction(android.R.drawable.ic_media_pause, "إيقاف الأذان", stopAdhanPendingIntent)
        
        // Show the notification
        notificationManager.notify(PRAYER_NOTIFICATION_ID, builder.build())
        
        // Register the action receiver
        NotificationActionReceiver.methodChannel = methodChannel
    }
    
    fun showAdkarNotification(title: String, message: String) {
        // Create an intent to open the app when notification is tapped
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.putExtra("notification_type", "adkar")
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build the notification
        val builder = NotificationCompat.Builder(context, ADKAR_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setColor(Color.BLUE)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
        
        // Show the notification
        notificationManager.notify(ADKAR_NOTIFICATION_ID, builder.build())
    }
    
    fun showAyahNotification(title: String, message: String) {
        // Create an intent to open the app when notification is tapped
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.putExtra("notification_type", "ayah")
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build the notification
        val builder = NotificationCompat.Builder(context, AYAH_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setColor(Color.MAGENTA)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
        
        // Show the notification
        notificationManager.notify(AYAH_NOTIFICATION_ID, builder.build())
    }
    
    fun cancelAllNotifications() {
        notificationManager.cancelAll()
    }
}
