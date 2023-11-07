package com.example.ca_mce_flutter_sdk

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.app.FlutterActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin


import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ActivityCompat
import android.os.Build

import android.util.Log
import android.content.Intent

import io.flutter.plugin.common.BinaryMessenger

import androidx.annotation.NonNull;





// import co.acoustic.mobile.push.sdk.api.notification.DelayedNotificationAction;

class MainActivity: FlutterActivity() {
    private var result: MethodChannel.Result? = null

    
    private var binaryMessenger: BinaryMessenger? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        handleIntent(getIntent())

        requestPermissions()

        Log.d("TAG, MAIN APPLICATION" , "SAMPLE MAIN ACTIVITY: onCreate")

    }

    override fun onResume() {
        super.onResume()
     
    }

    override fun onNewIntent(intent: Intent) {
      handleIntent(intent)
    }

       override fun configureFlutterEngine( flutterEngine: FlutterEngine) {
            super.configureFlutterEngine(flutterEngine)
            binaryMessenger = flutterEngine.getDartExecutor().getBinaryMessenger()   
        }

    fun handleIntent(intent: Intent){
        val action = intent.getAction();
        val type = intent.getType();

        if (OPEN_INBOX_ACTION.equals(action)) {

            val inboxContentId = intent.getStringExtra(EXTRA_CONTENT_ID)
            val inboxMessageId = intent.getStringExtra(EXTRA_MESSAGE_ID)

                try {
                    val bM = binaryMessenger
                    if(bM !== null) {
                         MethodChannel(bM, "flutter_acoustic_mobile_push_inbox_receiver").invokeMethod("inboxMessageNotification", inboxMessageId)
                    }
            } catch (ex: Exception) {
                Log.i("TAG, MAIN APPLICATION" , "Inbox Notification Exception")
            }
        }
    }

    private fun requestPermissions() {
        if (Build.VERSION.SDK_INT >= 33) {
            val primaryPermissions = arrayOf("android.permission.POST_NOTIFICATIONS")
            if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) {
                ActivityCompat.requestPermissions(
                        this,
                        primaryPermissions,
                        6
                )
            }
        }
    }

    companion object {
        const val OPEN_INBOX_ACTION = "co.acoustic.flutter.openInboxMessage"
        const val EXTRA_CONTENT_ID = "contentId"
        const val EXTRA_MESSAGE_ID = "inboxMessageId"

    }
}
