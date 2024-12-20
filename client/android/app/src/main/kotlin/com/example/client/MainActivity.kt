package com.example.client

import com.example.client.NotificationReceiver
import com.example.client.Audio
import com.example.client.Notification

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Context
import android.media.AudioManager
import android.media.AudioFocusRequest

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ActivityCompat
import android.Manifest
import android.content.pm.PackageManager
import android.widget.Toast

import android.os.CountDownTimer

import android.app.PendingIntent
import android.content.Intent


class MainActivity: FlutterActivity() {

  private lateinit var duration: String

  override fun onCreate(savedInstanceState: android.os.Bundle?) {
    super.onCreate(savedInstanceState)

    // Notification channel is created when the app is started
    Notification.createNotificationChannel(this)
  }

  // This function sets up the method channels that the Flutter application will be calling

  private val CHANNEL = "com.example.client/platform_methods"
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when(call.method) {

        "stopAudio" -> {
          val success = Audio.stopAudio(context)
          if (success) {
              result.success("All audio has been stopped")
          } else {
              result.error("ERROR_AUDIO_STOP", "Audio was not able to be stopped", null)
          }
        }

        "startBackgroundTimer" -> {
          duration = call.argument<String>("duration") ?: "0" // Get amount of minutes from flutter side

          if (Notification.isNotificationPermissionsGranted(this)) {
            Notification.createNotification(this, duration)
            result.success("Notification successfully posted")
          } else {
            Notification.requestNotificationPermissions(this)
          }
        }

        "stopBackgroundTimer" -> {
          Notification.closeNotification(this)
        }

        else -> {
          result.notImplemented()
        }

      }
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)

    // Check if the requestCode matches the one you used in requestPermissions()
    if (requestCode == 1) {
        // If the permission is granted, grantResults[0] will be PackageManager.PERMISSION_GRANTED
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            // Permission was granted, you can proceed with creating the notification
            Notification.createNotification(this, duration)
            // result.success("Notification successfully posted after permissions granted")
        } else {
            // Permission was denied, handle accordingly (e.g., show a message to the user)
            Toast.makeText(this, "Notification permission denied", Toast.LENGTH_SHORT).show()
            // result.error("PERMISSION_DENIED", "Notification permissions denied", null)
        }

    }
  }

}