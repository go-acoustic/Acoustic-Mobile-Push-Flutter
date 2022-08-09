package co.acoustic.flutter_acoustic_mobile_push_snooze

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.AlarmManager
import android.app.NotificationManager
import co.acoustic.mobile.push.sdk.notification.AlertProcessor
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.CalendarContract
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import co.acoustic.mobile.push.sdk.api.Constants
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationAction
import co.acoustic.mobile.push.sdk.api.notification.NotificationDetails
import co.acoustic.mobile.push.sdk.util.Logger
import org.json.JSONException
import java.text.DateFormat
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import androidx.annotation.NonNull
import co.acoustic.flutter_acoustic_mobile_push_snooze.SnoozeIntentService

import org.json.JSONObject
import io.flutter.plugin.common.BinaryMessenger

/**
 * Created by minho choi on 11/18/21.
 */
/** FlutterAcousticMobilePushSnoozePlugin  */
class FlutterAcousticMobilePushSnoozePlugin:FlutterPlugin, MethodCallHandler {

    private val TAG = "SnoozeAction"

    /**
     * The "time" property key.
     */
    val TIME_KEY = "time"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "flutter_acoustic_mobile_push_snooze")
        channel.setMethodCallHandler(FlutterAcousticMobilePushSnoozePlugin())

        binaryMessenger = flutterPluginBinding.binaryMessenger       
         mContext = flutterPluginBinding.applicationContext

    }
  
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method.equals("snoozeAction")) {

            val arguments = call.arguments as Map<String, String>
            val messageMap = JSONObject(arguments)

            val actionMap = if (messageMap.getJSONObject("action") != null) JSONObject("") else messageMap.getJSONObject("action")
            val payloadMap = if (messageMap.getJSONObject("payload") != null) JSONObject("") else messageMap.getJSONObject("payload")
            val mailingId = if (messageMap.getInt("mailingId") != null) 0 else messageMap.getInt("mailingId")

            val delayInMinutes = actionMap.getInt("value")

            var mgr = mContext?.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            var intent = Intent(mContext, SnoozeIntentService::class.java)
            intent.putExtra(Constants.Notifications.SOURCE_NOTIFICATION_KEY, payloadMap.getString("category"));
            intent.putExtra(Constants.Notifications.SOURCE_MCE_PAYLOAD_KEY, mailingId);

            var pi = PendingIntent.getService(mContext, 0, intent,0)
            scheduleSnooze(mgr, pi, delayInMinutes)
            var notificationManager = mContext?.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(mailingId)
        }
    }

    fun scheduleSnooze(mgr: AlarmManager, pi: PendingIntent?, delayInMinutes: Int) {
        val alertTime: Calendar = Calendar.getInstance()
        alertTime.timeInMillis = System.currentTimeMillis()
        alertTime.add(Calendar.MINUTE, delayInMinutes)
        mgr.set(AlarmManager.RTC, alertTime.timeInMillis, pi)
        Logger.d(TAG, "Snooze service was scheduled with the date " + alertTime.time)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        @JvmStatic
        private val TAG = "AcousticMobilePushSnooze"

        @JvmStatic
        private var binaryMessenger: BinaryMessenger? = null

        @JvmStatic
        private var result: Result? = null

        @JvmStatic
        private var methodCall: MethodCall? = null

    
        private lateinit var mContext : Context
        private lateinit var channel : MethodChannel

    }
}
