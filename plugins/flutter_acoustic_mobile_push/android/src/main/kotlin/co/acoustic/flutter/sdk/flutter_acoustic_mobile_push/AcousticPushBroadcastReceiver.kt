package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push

import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Bundle
import co.acoustic.mobile.push.sdk.api.MceBroadcastReceiver
import co.acoustic.mobile.push.sdk.api.attribute.AttributesOperation
import co.acoustic.mobile.push.sdk.api.broadcast.EventBroadcastHandler
import co.acoustic.mobile.push.sdk.api.event.Event
import co.acoustic.mobile.push.sdk.api.notification.NotificationDetails
import co.acoustic.mobile.push.sdk.location.MceLocation
import java.util.*

import android.util.Log
import org.json.JSONObject

/**
 * Created by minho choi on 11/3/21.
 */
class AcousticPushBroadcastReceiver: MceBroadcastReceiver() {
    val TAG = "!!@@BroadcastReceiver"

    override fun onSdkRegistered(p0: Context?) {
        Log.e(TAG, "onSdkRegistered")
    }

    override fun onMessagingServiceRegistered(p0: Context?) {
        Log.e(TAG, "onMessagingServiceRegistered")
    }

    override fun onSdkRegistrationChanged(p0: Context?) {
        Log.e(TAG, "onSdkRegistrationChanged")

    }

    override fun onSdkRegistrationUpdated(p0: Context?) {
        Log.e(TAG, "onSdkRegistrationUpdated")

    }

    override fun onMessage(p0: Context?, p1: NotificationDetails?, p2: Bundle?) {
        Log.e(TAG, "onMessage")

    }

    override fun onC2dmError(p0: Context?, p1: String?) {
        Log.e(TAG, "onC2dmError")

    }

    override fun onSessionStart(p0: Context?, p1: Date?) {
        Log.e(TAG, "onSessionStart")

    }

    override fun onSessionEnd(p0: Context?, p1: Date?, p2: Long) {
        Log.e(TAG, "onSessionEnd")

    }

    override fun onNotificationAction(
        p0: Context?,
        p1: Date?,
        p2: String?,
        p3: String?,
        p4: String?
    ) {
        Log.e(TAG, "onNotificationAction")

    }

    override fun onAttributesOperation(p0: Context?, p1: AttributesOperation?) {
        Log.e(TAG, "onAttributesOperation")

    }

    override fun onEventsSend(p0: Context?, p1: MutableList<Event>?) {
        Log.e(TAG, "onEventsSend")

    }

    override fun onNonMceBroadcast(p0: Context?, p1: Intent?) {
        Log.e(TAG, "onNonMceBroadcast")

    }

    override fun onIllegalNotification(p0: Context?, p1: Intent?) {
        Log.e(TAG, "onIllegalNotification")

    }

    override fun onLocationEvent(
        context: Context?,
        location: MceLocation?,
        locationType: EventBroadcastHandler.LocationType?,
        locationEventType: EventBroadcastHandler.LocationEventType?
    ) {

        val jsonObject = JSONObject()
        jsonObject.put("id", location?.id)
        Log.e(TAG, "onLocationEvent")
        if (locationType == EventBroadcastHandler.LocationType.ibeacon) {
            if (locationEventType == EventBroadcastHandler.LocationEventType.enter) {
                FlutterAcousticSdkPushPlugin.sendEvent("EnterBeacon", jsonObject.toString())
            } else if  (locationEventType == EventBroadcastHandler.LocationEventType.exit) {
                FlutterAcousticSdkPushPlugin.sendEvent("ExitedBeacon", jsonObject.toString())
            }

        } else if (locationType == EventBroadcastHandler.LocationType.geofence) {
            if (locationEventType == EventBroadcastHandler.LocationEventType.enter) {
                FlutterAcousticSdkPushPlugin.sendEvent("EnteredGeofence", jsonObject.toString())
            } else if  (locationEventType == EventBroadcastHandler.LocationEventType.exit) {
                FlutterAcousticSdkPushPlugin.sendEvent("ExitedGeofence", jsonObject.toString())
            }
        }
    }

    override fun onLocationUpdate(p0: Context?, p1: Location?) {
        Log.e(TAG, "onLocationUpdate")

    }

    override fun onActionNotYetRegistered(p0: Context?, p1: String?) {
        Log.e(TAG, "onActionNotYetRegistered")

    }

    override fun onActionNotRegistered(p0: Context?, p1: String?) {
        Log.e(TAG, "onActionNotRegistered")

    }

    override fun onInboxCountUpdate(p0: Context?) {
        Log.e(TAG, "onInboxCountUpdate")

    }
}