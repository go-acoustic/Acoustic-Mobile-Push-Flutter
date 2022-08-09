package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.customAction

import android.content.Context
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.MutableLiveData
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.FlutterAcousticSdkPushPlugin
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.convertJsonArray
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.convertJsonObject
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationAction
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import co.acoustic.mobile.push.sdk.api.notification.NotificationDetails
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import org.json.JSONException

import org.json.JSONArray
import java.lang.Exception


/**
 * Created by minho choi on 11/10/21.
 */
class AcousticCustomActionModule {

    companion object {
        private var registerActions: HashMap<String, MethodChannel.Result> = HashMap()

        var data: MutableLiveData<Any?> = MutableLiveData()
        val TAG = "AcousticCustomAction"

        fun unregisterAction(context: Context, name: String, result: MethodChannel.Result) {
            MceNotificationActionRegistry.registerNotificationAction(context, name, null)
            if (registerActions.containsKey(name)) {
                registerActions.remove(name)
                result.success("Unregistering Custom Action: $name")
            } else {
                result.success("Custom action TEST: $name is not registered")
            }
        }

        fun registerAction(context: Context, name: String, result: MethodChannel.Result) {
            if (registerActions.containsKey(name)) {
                result.success("Custom action type $name is already registered")
            } else {
                registerActions[name] = result
                result.success("Registering Custom Action: $name")
            }

            MceNotificationActionRegistry.registerNotificationAction(context, name,
                object : MceNotificationAction {
                    override fun handleAction(
                        context: Context?,
                        type: String?,
                        name: String?,
                        attribution: String?,
                        mailingId: String?,
                        payload: MutableMap<String, String>,
                        fromNotification: Boolean
                    ) {
                        Log.e("MceNotificationAction", "handleAction : $name")

                        var actionMap: HashMap<String, Any?> = convertPayloadToMap(type, name, payload)

                        var map: HashMap<String, Any?> = HashMap()
                        map["action"] = actionMap;

                        var mce: HashMap<String, Any?> = HashMap()
                        if(attribution.isNullOrEmpty().not()) {
                            mce["attribution"] = attribution
                        }
                        if(mailingId.isNullOrEmpty().not()) {
                            mce["mailingId"] = mailingId
                        }

                        val sourceValue = payload["co.acoustic.mobile.push.sdk.NOTIF_SOURCE"]
                        var payloadMap = try {
                            convertJsonObject(JSONObject(sourceValue))
                        } catch (e: Exception) {
                            null
                        }
                        if (payloadMap == null) {
                            payloadMap = HashMap()
                        }

                        payloadMap["mce"] = mce
                        map["payload"] = payloadMap
                        Log.e(TAG, "payload : $map")
                        data.postValue(map)
                        if (type != null) {
                            FlutterAcousticSdkPushPlugin.sendEvent(type, map)
                        }
                    }

                    override fun init(p0: Context?, p1: JSONObject?) {

                    }

                    override fun update(p0: Context?, p1: JSONObject?) {

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

                })
        }

        fun convertPayloadToMap(type: String?, name: String?, payload: Map<String, String>): HashMap<String, Any?> {
            var actionMap: HashMap<String, Any?> = HashMap()

            if (type.isNullOrEmpty().not()) {
                actionMap["type"] = type
            }
            if (name.isNullOrEmpty().not()) {
                actionMap["name"] = name
            }

            val payloadIterator: Iterator<String> = payload.keys.iterator()
            while (payloadIterator.hasNext()) {
                val key = payloadIterator.next()
                if (key.startsWith("co.acoustic.mobile.push.sdk")) {
                    continue
                }
                val value: Any? = payload[key]
                if (value is String) {
                    if (value.startsWith("[") && value.endsWith("]")) {
                        try {
                            val jsonValue = JSONArray(value)
                            actionMap[key] = convertJsonArray(jsonValue)
                        } catch (e: JSONException) {
                            actionMap[key] = value
                        }
                    } else if (value.startsWith("{") && value.endsWith("}")) {
                        try {
                            val jsonValue = JSONObject(value)
                            actionMap[key] = convertJsonObject(jsonValue)
                        } catch (e: JSONException) {
                            actionMap[key] = value
                        }
                    } else {
                        actionMap[key] = value
                    }
                }
            }
            return actionMap
        }
    }
}