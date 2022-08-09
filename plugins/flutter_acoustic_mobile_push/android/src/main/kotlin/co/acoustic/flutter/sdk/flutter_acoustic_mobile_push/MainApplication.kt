package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.util.Log
import co.acoustic.mobile.push.sdk.api.MceApplication
import co.acoustic.mobile.push.sdk.api.MceSdkConfiguration
import co.acoustic.mobile.push.sdk.api.SdkInitLifecycleCallbacks
import com.google.firebase.FirebaseApp
import org.json.JSONObject
import co.acoustic.mobile.push.sdk.api.MceSdk
import android.app.NotificationChannel
import android.app.NotificationManager
import co.acoustic.mobile.push.sdk.api.notification.NotificationsPreference
import android.os.Build
import androidx.annotation.RequiresApi;


/**
 * Created by minho choi on 11/18/21.
 */
class MainApplication: MceApplication() {

    companion object {
        const val displayWeb = "displayWeb"
        const val snooze = "snooze"
    }

    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this.applicationContext)
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }


        Log.d("TAG, MAIN" , "PLUGIN MAIN APPLICATION: onCreate")
    }

    override fun handleMetadata(metadata: Bundle?) {
        super.handleMetadata(metadata)
    }

    override fun onPluginActionLoad(action: JSONObject?) {
        super.onPluginActionLoad(action)
    }

    override fun onPluginNotificationTypeLoad(type: JSONObject?) {
        super.onPluginNotificationTypeLoad(type)
    }

    override fun onPluginMessageProcessorLoad(messageProcessor: JSONObject?) {
        super.onPluginMessageProcessorLoad(messageProcessor)
    }

    override fun onStart(mceSdkConfiguration: MceSdkConfiguration?) {
        super.onStart(mceSdkConfiguration)
    }

    override fun onSdkReinitializeNeeded(context: Context?) {
        super.onSdkReinitializeNeeded(context)
    }

    override fun getMceSdkConfiguration(): MceSdkConfiguration {
        return super.getMceSdkConfiguration()
    }

    override fun init(callbacks: SdkInitLifecycleCallbacks?) {
        super.init(callbacks)
    }


     @RequiresApi(Build.VERSION_CODES.O)
  private fun createNotificationChannel() {

    var channelDescription = "This is the notification channel for the MCE SDK sample application"
    var channelName: CharSequence = "MCE SDK Notification Channel"
    var channelIdentifier = "mce_sample_channel"


    val notificationManager =
      getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    var channel = notificationManager.getNotificationChannel(channelIdentifier)
    if (channel == null) {
      val importance = NotificationManager.IMPORTANCE_HIGH
      channel = NotificationChannel(channelIdentifier, channelName, importance)
      channel.description = channelDescription
      channel.setShowBadge(true)
      val notificationsPreference = MceSdk.getNotificationsClient().notificationsPreference
      notificationsPreference.setNotificationChannelId(this, channelIdentifier)
      notificationManager.createNotificationChannel(channel)
    }
  }
}