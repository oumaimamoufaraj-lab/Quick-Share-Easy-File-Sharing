package com.quickshare.easyfilesharing

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class ReceiveForegroundService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val deviceName = intent?.getStringExtra(EXTRA_DEVICE_NAME) ?: "Quick Share"
        val notification = buildNotification(deviceName)
        startForeground(NOTIFICATION_ID, notification)
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            "File receiving",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Keeps Quick Share active while receiving files."
            setShowBadge(false)
        }

        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }

    private fun buildNotification(deviceName: String): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Receiving files")
            .setContentText("Quick Share is ready on $deviceName")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    companion object {
        const val CHANNEL_ID = "quick_share_receive"
        const val NOTIFICATION_ID = 1001
        const val EXTRA_DEVICE_NAME = "device_name"

        fun start(context: Context, deviceName: String) {
            val intent = Intent(context, ReceiveForegroundService::class.java).apply {
                putExtra(EXTRA_DEVICE_NAME, deviceName)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, ReceiveForegroundService::class.java))
        }
    }
}
