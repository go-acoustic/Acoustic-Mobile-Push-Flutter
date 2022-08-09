package co.acoustic.flutter_acoustic_mobile_push_calendar;

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import java.util.TimeZone


import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.os.Bundle
import android.provider.CalendarContract
import io.flutter.plugin.common.BinaryMessenger
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationAction
import co.acoustic.mobile.push.sdk.api.notification.NotificationDetails

import co.acoustic.mobile.push.sdk.util.Logger
import org.json.JSONException
import org.json.JSONObject
import java.text.DateFormat
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

/** FlutterAcousticMobilePushCalendarPlugin */
public class FlutterAcousticMobilePushCalendarPlugin : FlutterPlugin, MethodCallHandler, MceNotificationAction {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    companion object {
        @JvmStatic
        private val TAG = "AcousticCalendarPlugin"
        @JvmStatic
        private var methodCall: MethodCall? = null

        @JvmStatic
        private var binaryMessenger: BinaryMessenger? = null

        @JvmStatic
        private val Registered = "Registered"
        private val RegistrationChanged = "RegistrationChanged"

        private lateinit var mContext : Context
        private lateinit var mActivity : Activity
        private lateinit var channel : MethodChannel

    }

    val EVENT_START_KEY = "startDate"
    val EVENT_END_KEY = "endDate"
    val EVENT_TITLE_KEY = "title"
    val EVENT_DESCRIPTION_KEY = "description"
    val DATE_KEY = "date"
    val TIME_KEY = "time"
    val TIMEZONE_KEY = "timezone"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.e(TAG, "onAttachedToEngine")

        binaryMessenger = flutterPluginBinding.binaryMessenger
        mContext = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "flutter_acoustic_mobile_push_calendar")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        FlutterAcousticMobilePushCalendarPlugin.methodCall = call
        if (call.method.equals("calendarAction")) {
            MceNotificationActionRegistry.registerNotificationAction(mContext, "calendar", FlutterAcousticMobilePushCalendarPlugin());
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
    
    // fun updateUserAttributes(context: Context, attibuteMap: Map<String, String>) {
    //     var jsonObject = JSONObject(attibuteMap)

    //     val type = jsonObject.getString("type")

    //     val attributes = convertJsonToAttribute(JSONObject(attibuteMap))
    //     try {
    //         Log.e("Attribute-->", "$attributes")
    //         MceSdk.getQueuedAttributesClient().updateUserAttributes(context, attributes)
    //     } catch (ex: Exception) {
    //         Log.e(TAG, "Couldn't update user attriubtes", ex)
    //     }
    // }
    override fun handleAction(
        context: Context?,
        type: String?,
        name: String?,
        attributionp: String?,
        mailingId: String?,
        payload: MutableMap<String, String>?,
        fromNotification: Boolean
    ) {

        val it = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
        context!!.sendBroadcast(it)
        val intent = Intent(Intent.ACTION_INSERT)
        intent.type = "vnd.android.cursor.item/event"

        try {
            val starts: JSONObject = JSONObject(payload!![EVENT_START_KEY])
            addTime(intent, CalendarContract.EXTRA_EVENT_BEGIN_TIME, starts)
            val ends: JSONObject = JSONObject(payload!![EVENT_END_KEY])
            addTime(intent, CalendarContract.EXTRA_EVENT_END_TIME, ends)
            intent.putExtra(CalendarContract.Events.TITLE, payload!![EVENT_TITLE_KEY])
            intent.putExtra(CalendarContract.Events.DESCRIPTION, payload!![EVENT_DESCRIPTION_KEY])
            context.startActivity(intent)
        } catch (e: JSONException) {
            Log.e(TAG, "Failed to handle AddToCalendarAction", e)
        } catch (e: ParseException) {
            Log.e(TAG, "Failed to handle AddToCalendarAction", e)
        }
    }

    override fun init(p0: Context?, p1: JSONObject?) {
        TODO("Not yet implemented")
    }

    override fun update(p0: Context?, p1: JSONObject?) {
        TODO("Not yet implemented")
    }

    override fun shouldDisplayNotification(
        p0: Context?,
        p1: NotificationDetails?,
        p2: Bundle?
    ): Boolean {

        return true
    }

    override fun shouldSendDefaultEvent(p0: Context?): Boolean {
        return true
    }

    @Throws(JSONException::class, ParseException::class)
    fun addTime(intent: Intent, key: String, timeJSON: JSONObject) {
        val date = timeJSON.getString(DATE_KEY)
        val time = timeJSON.getString(TIME_KEY)
        val timezoneId = timeJSON.getString(TIMEZONE_KEY)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.putExtra(key, getTimeInMillis(date, time, parseTimezone(timezoneId)))
    }

    @Throws(ParseException::class)
     fun getTimeInMillis(date: String, time: String, timeZone: TimeZone): Long {
        val format: DateFormat = SimpleDateFormat("yyyy-MM-dd-HH:mm")
        format.timeZone = timeZone
        return format.parse("$date-$time").time
    }

    fun parseTimezone(timezoneId: String): TimeZone {
        val availableTimezoneIds: Array<String> = TimeZone.getAvailableIDs()
        for (id in availableTimezoneIds) {
            if (id == timezoneId) {
                return TimeZone.getTimeZone(id)
            }
        }
        return TimeZone.getDefault()
    }
}