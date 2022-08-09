package co.acoustic.flutter_acoustic_mobile_push_snooze

import android.app.AlarmManager
import android.app.IntentService
import android.app.PendingIntent
import android.content.Intent
import android.os.Bundle
import co.acoustic.mobile.push.sdk.api.Constants
import co.acoustic.mobile.push.sdk.notification.AlertProcessor
import co.acoustic.mobile.push.sdk.util.Logger
import org.json.JSONException
import java.util.*


/**
 * Created by minho choi on 11/18/21.
 */
class SnoozeIntentService: IntentService("Snooze") {
    private val TAG = "SnoozeIntentService"

    override fun onHandleIntent(intent: Intent?) {
        Logger.d(TAG, "Snooze done")
        val extras = Bundle()
        extras.putString(
            Constants.Notifications.ALERT_KEY,
            intent!!.getStringExtra(Constants.Notifications.SOURCE_NOTIFICATION_KEY)
        )
        extras.putString(
            Constants.Notifications.MCE_PAYLOAD_KEY,
            intent.getStringExtra(Constants.Notifications.SOURCE_MCE_PAYLOAD_KEY)
        )
        try {
            AlertProcessor.processAlert(applicationContext, extras)
        } catch (jsone: JSONException) {
            Logger.e(TAG, "Failed to parse notification", jsone)
        }
    }

    fun scheduleSnooze(mgr: AlarmManager, pi: PendingIntent?, delayInMinutes: Int) {
        val alertTime: Calendar = Calendar.getInstance()
        alertTime.timeInMillis = System.currentTimeMillis()
        alertTime.add(Calendar.MINUTE, delayInMinutes)
        mgr.set(AlarmManager.RTC, alertTime.timeInMillis, pi)
        Logger.d(TAG, "Snooze service was scheduled with the date " + alertTime.time)
    }
}