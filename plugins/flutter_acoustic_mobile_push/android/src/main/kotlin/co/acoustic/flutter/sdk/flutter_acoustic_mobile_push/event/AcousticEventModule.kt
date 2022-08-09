package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.event

import android.app.Activity
import android.content.Context
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.convertReadableMapToAttributes
import co.acoustic.mobile.push.sdk.api.MceSdk
import co.acoustic.mobile.push.sdk.api.attribute.*
import co.acoustic.mobile.push.sdk.api.event.Event
import co.acoustic.mobile.push.sdk.util.Logger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.lang.Exception
import java.text.SimpleDateFormat
import java.util.*
import android.view.DisplayCutout

import android.os.Build
import android.util.Log
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.convertJsonToAttribute
import org.json.JSONArray


/**
 * Created by minho choi on 11/16/21.
 */
class AcousticEventModule {

    companion object {

        @JvmStatic
        val TAG = "AcousticEventModule"

        @JvmStatic
        fun createEvent(context: Context, event: Map<String, String>) {
            val eventMap = JSONObject(event)

            val type: String? = if (eventMap.getString("type").isNullOrEmpty()) null else eventMap.getString("type")
            val name: String? = if (eventMap.getString("name").isNullOrEmpty()) null else eventMap.getString("name")
            val timestampString: String? = if (eventMap.getString("timestamp").isNullOrEmpty()) null else eventMap.getString("timestamp")

            var timestamp: Date? = null
            
            val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'")

                try {
                    timestamp = dateFormat.parse(timestampString)
                    Logger.i(TAG, "New Date $timestamp")

                } catch (ex: Exception) {
                    Logger.i(TAG, "Couldn't parse date from string $timestampString", ex)
                }

            var attributes: MutableList<Attribute> = ArrayList()
            val attributesMap  = eventMap.getJSONArray("attributes")

           if(attributesMap != null){
           
            for (item in 0 until attributesMap.length()){
                val jsonMap = JSONObject(attributesMap[item].toString())
                val key = jsonMap.getString("key")
                val value = jsonMap.getString("value")
                val type = jsonMap.getString("type")

                if(type == "string"){
                    attributes.add(StringAttribute(key, value));
                } else if(type == "number"){
                    attributes.add(NumberAttribute(key, value.toInt()));
                } else if(type == "boolean"){
                    attributes.add(BooleanAttribute(key, value.toBoolean()));
                } 
            }
           }

            var mailingId: String = "" 
            var attribution: String = "" 

            if(eventMap.has("mailingId")){
                mailingId = eventMap.getString("mailingId") 
            }
            if(eventMap.has("attribution")){
                attribution = eventMap.getString("mailingId") 
            }

            val event = Event(type, name, timestamp, attributes, attribution, mailingId)
            MceSdk.getQueuedEventsClient().sendEvent(context, event, false); 
        }

        @JvmStatic
        fun addEvent(context: Context, event: Map<String, String>) {
            val eventMap = JSONObject(event)
            val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'")

            val type: String? = if (eventMap.getString("type").isNullOrEmpty()) null else eventMap.getString("type")
            val name: String? = if (eventMap.getString("name").isNullOrEmpty()) null else eventMap.getString("name")
            val timestampString: String? = if (eventMap.getString("timestamp").isNullOrEmpty()) null else eventMap.getString("timestamp")

            var timestamp: Date? = null
            if (timestampString.isNullOrEmpty().not()) {
                try {
                    timestamp = dateFormat.parse(timestampString)
                } catch (ex: Exception) {
                    Logger.i(TAG, "Couldn't parse date from string $timestampString", ex)
                }
            }

            if (timestamp == null) {
                timestamp = Date()
                Logger.i(TAG, "Using current timestamp for event date.")
            }

            var attributes: List<Attribute>? = null
            val attributesMap: String? = if (eventMap.getString("attributes").isNullOrEmpty()) null else eventMap.getString("attributes")

            if(attributesMap != null) {
                attributes = convertJsonToAttribute(JSONObject(attributesMap))
            }

            if (attributes == null) {
                attributes = LinkedList<Attribute>()
            }

            val mailingId: String? = if (eventMap.getString("mailingId").isNullOrEmpty()) null else eventMap.getString("mailingId")
            val attribution: String? = if (eventMap.getString("attribution").isNullOrEmpty()) null else eventMap.getString("attribution")

            val event = Event(type, name, timestamp, attributes, attribution, mailingId)
            MceSdk.getQueuedEventsClient().sendEvent(context, event, eventMap.optBoolean("immediate", false))
            
        }

        @JvmStatic
        fun getSafeAreaInsets(activity: Activity, result: MethodChannel.Result) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                if (activity != null) {
                    val cutout = activity.window.decorView.rootWindowInsets.displayCutout
                    if (cutout != null) {
                        val map = JSONObject()
                        map.put("left", cutout.safeInsetLeft)
                        map.put("right", cutout.safeInsetRight)
                        map.put("top", cutout.safeInsetTop)
                        map.put("bottom", cutout.safeInsetBottom)
                        result.success(map.toString())
                        return
                    }
                }
            }
            val map = JSONObject()
            map.put("left", 0)
            map.put("right", 0)
            map.put("top", 0)
            map.put("bottom", 0)
            result.success(map.toString())
        }

        @JvmStatic
        fun updateUserAttributesList(context: Context, attibuteMap:List<*>) {
            var attributesPayload: MutableList<Attribute> = ArrayList()
            for(attribute in attibuteMap){
               val nameTable = mutableMapOf<String, String>()

               if(attribute is Map<*, *>){
                   val map:Map<*, *> = attribute
                   map.forEach { entry ->
                       nameTable.set(entry.key.toString(), entry.value.toString())
                   } 
               }

               if(nameTable.containsKey("type") && nameTable.containsKey("value") && nameTable.containsKey("key")){
                  
                   val key = nameTable.getValue("key") 
                   val value = nameTable.getValue("value") 
                   val type = nameTable.getValue("type") 
   
                   if(type == "string"){
                       attributesPayload.add(StringAttribute(key, value));
                   } else if(type == "number"){
                       attributesPayload.add(NumberAttribute(key, value.toInt()));
                   } else if(type == "boolean"){
                       attributesPayload.add(BooleanAttribute(key, value.toBoolean()));
                    } //else if(type == "date"){
                //     val dateFormat = SimpleDateFormat("yyyy-MM-dd")
                //     attributesPayload.add(DateAttribute(key, dateFormat.parse(value)));
                //    }
               }
           
               }

               Logger.i("updateAttribute", attributesPayload.toString())

           try {
               MceSdk.getQueuedAttributesClient().updateUserAttributes(context, attributesPayload)
           } catch (ex: Exception) {
               Logger.e(TAG, "Couldn't update user attriubtes", ex)
           }

        }

        @JvmStatic
        fun updateUserAttributes(context: Context, attibuteMap: Map<String, String>) {
            var event = JSONObject(attibuteMap)
            val attributes = convertJsonToAttribute(JSONObject(attibuteMap))
            try {
                MceSdk.getQueuedAttributesClient().updateUserAttributes(context, attributes)
            } catch (ex: Exception) {
                Logger.e(TAG, "Couldn't update user attriubtes", ex)
            }
        }

        @JvmStatic
        fun deleteUserAttributesList(context: Context, keys: List<String>) {
             val keyList: MutableList<String> = ArrayList()
             for(keyName in  keys){
                Logger.i("updateAttribute", keyName.toString())
                keyList.add(keyName)
             }

            try {
                MceSdk.getQueuedAttributesClient().deleteUserAttributes(context, keyList)
            } catch (ex: Exception) {
                Logger.e(TAG, "Couldn't delete user attributes", ex)
            }
        }
    
    @JvmStatic
    fun deleteUserAttributes(context: Context, keys: JSONArray) {
        val keyList: MutableList<String> = ArrayList()
        for (i in 0 until keys.length()) {
            val jsonObject = keys[i] as JSONObject
            val key = jsonObject.getString("key")
            if (key.isNullOrEmpty().not()) {
                keyList.add(key)
            } else {
                Logger.e(TAG, "deleteUserAttribtes key list contains non string value.")
            }
        }
        try {
            MceSdk.getQueuedAttributesClient().deleteUserAttributes(context, keyList)
        } catch (ex: Exception) {
            Logger.e(TAG, "Couldn't delete user attributes", ex)
        }
    }
}
}