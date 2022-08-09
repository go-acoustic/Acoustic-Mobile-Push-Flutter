package co.acoustic.flutter_acoustic_mobile_push_inapp

import android.app.Activity
import android.content.Context
import android.graphics.Color
import org.json.JSONArray
import org.json.JSONObject
import java.text.AttributedCharacterIterator
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.widget.FrameLayout
import android.widget.RelativeLayout
import android.widget.TextView
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.FlutterAcousticSdkPushPlugin
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.convertJsonObjectToBundle
import co.acoustic.mobile.push.sdk.api.OperationCallback
import co.acoustic.mobile.push.sdk.api.OperationResult
import co.acoustic.mobile.push.sdk.api.message.MessageSync
import co.acoustic.mobile.push.sdk.plugin.inapp.*
import co.acoustic.mobile.push.sdk.util.Logger
import java.lang.Exception
import co.acoustic.mobile.push.sdk.plugin.inapp.InAppManager
import co.acoustic.mobile.push.sdk.api.MceSdk
import co.acoustic.mobile.push.sdk.api.attribute.Attribute
import co.acoustic.mobile.push.sdk.api.attribute.StringAttribute
import co.acoustic.mobile.push.sdk.api.event.Event
import co.acoustic.mobile.push.sdk.notification.MceNotificationActionImpl
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationAction
import co.acoustic.mobile.push.sdk.notification.MceNotificationActionImpl.ClickEventDetails
import co.acoustic.mobile.push.sdk.plugin.inapp.InAppStorage
import co.acoustic.mobile.push.sdk.plugin.inapp.InAppPayload
import io.flutter.plugin.common.BinaryMessenger
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import androidx.annotation.NonNull
import androidx.annotation.UiThread
import androidx.core.app.ActivityCompat

import java.time.LocalDateTime





/**
 * Created by minho choi on 11/9/21.
 */

enum class CannedInAppTypes {
    BOTTOM, TOP, VIDEO, IMAGE
}

/** FlutterAcousticMobilePushInappPlugin  */
class FlutterAcousticMobilePushInappPlugin : FlutterPlugin, MethodCallHandler{
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_acoustic_mobile_push_inapp")
        channel.setMethodCallHandler(this)

        binaryMessenger = flutterPluginBinding.binaryMessenger
        mContext = flutterPluginBinding.applicationContext

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        FlutterAcousticMobilePushInappPlugin.result = result
        FlutterAcousticMobilePushInappPlugin.methodCall = call

        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "cannedInAppBottomBanner" -> {
                createInApp(mContext, call.arguments, 0)
            }
            "cannedInAppTopBanner" -> {
                createInApp(mContext, call.arguments, 1)
            }
            "cannedInAppImageBanner" -> {
                createInApp(mContext, call.arguments, 2)
            }
            "cannedInAppVideoBanner" -> {
                createInApp(mContext, call.arguments, 3)
            }
            "getSync" -> {
                syncInAppmessages(mContext, result)
            }
            "getInAppMessageTemplate" -> {
                executeInApp(mContext, call.arguments as List<String>)
            }
             "deleteInApp" -> {
                deleteInApp(mContext, call.arguments as String )
            }
             "clickInApp" -> {
                clickInApp(mContext, call.arguments as String? )
            }
             "recordViewForInAppMessage" -> {
                recordViewForInAppMessage(mContext, call.arguments as String? )
            }
            "cannedInAppContent" -> {
                val map = call.arguments as HashMap<String, Any?>
                Log.d("SendInAppContent", map.toString())
                sendInApp(mContext, call.arguments as HashMap<String, Any?>)        
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {

        @JvmStatic
        private var result: Result? = null

        @JvmStatic
        private var methodCall: MethodCall? = null

        @JvmStatic
        private var binaryMessenger: BinaryMessenger? = null

        @JvmStatic
        fun sendEvent(any: Any?) {
            result?.let {
                it.success(any)
            }
        }

        @JvmStatic
        @UiThread
        fun sendEvent(methodName: String, any: Any?) {
            try {
                MethodChannel(binaryMessenger, "flutter_acoustic_mobile_push_inapp")
                        .invokeMethod(methodName,any)
            } catch (ex: Exception) {
                Log.e("Exception sendEvent", "${ex.localizedMessage}")
            }
        }

        @JvmStatic
        private val LocationAuthorization = "LocationAuthorization"

        @JvmStatic
        private val TAG = "AcousticPushInAppModule"
    
        @JvmStatic
        var relativeLayout: RelativeLayout? = null
    
        @JvmStatic
        internal var inAppRegistry: HashMap<String, ModuleHeight> = HashMap()

        @JvmStatic
        private val DownloadedLocations = "DownloadedLocations"
        private val CustomPushNotYetRegistered = "CustomPushNotYetRegistered"
        private val CustomPushNotRegistered = "CustomPushNotRegistered"
        private val Registered = "Registered"
        private val RegistrationChanged = "RegistrationChanged"
        private val UpdateUserAttributesSuccess = "UpdateUserAttributesSuccess"
        private val DeleteUserAttributesSuccess = "DeleteUserAttributesSuccess"
        private val EventSuccess = "EventSuccess"
        private val InboxCountUpdate = "InboxCountUpdate"
        private val EnteredBeacon = "EnteredBeacon"
        private val ExitedBeacon = "ExitedBeacon"
        private val EnteredGeofence = "EnteredGeofence"
        private val ExitedGeofence = "ExitedGeofence"
        private val SyncInbox = "SyncInbox"


        private lateinit var mContext : Context
        private lateinit var mActivity : Activity
        private lateinit var channel : MethodChannel

        var channelDescription = "This is the notification channel for the MCE SDK sample application"
        var channelName: CharSequence = "MCE SDK Notification Channel"
        var channelIdentifier = "mce_sample_channel"

    }


    internal class ModuleHeight(var module: String, var height: Int)

    fun createCannedInAppString(template: String, attribution: String, mailingId: String, rule: String, title: String): String {

        var imageValue = "null"
        if (rule == "image") {
            imageValue = "https://www.nasa.gov/sites/default/files/styles/image_card_4x3_ratio/public/thumbnails/image/hubble_sstgbsj1109261_ic2631_display1_0.jpg"
        }

        var videoValue = "null"
        if (rule == "video") {
            videoValue = "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        }
        var currentDate : Any
        var currentExpDatePlusOne : Any
        var currentTriggerDateMinusOne : Any
        if (android.os.Build.VERSION.SDK_INT > 25) { 
            currentDate = LocalDateTime.now()
            currentExpDatePlusOne = currentDate.plusDays(1)
            currentTriggerDateMinusOne = currentDate.minusDays(1)
        } else {
            currentDate = "2022-06-17T10:15:30"
            currentExpDatePlusOne = "2030-06-17T10:15:30"
            currentTriggerDateMinusOne = "2022-06-15T10:15:30"
        }

        val bottomBannerString = "{\"triggerDate\":\"${currentTriggerDateMinusOne}+0000\",\"numViews\":0,\"maxViews\":5,\"contentId\":null,\"rules\":[\"${rule}\",\"all\"],\"mailingId\":\"${mailingId}\",\"template\":\"${template}\",\"attribution\":\"${attribution}\",\"id\":\"qG2d7HqOqglo90WE\",\"actions\":null,\"views\":0,\"expirationDate\":\"${currentExpDatePlusOne}+0000\",\"content\":{\"title\":\"${title}\",\"text\":\"This is a test message displayed with a banner\",\"mainImage\":\"https://cdn3.dpmag.com/2020/09/9-14-Autumn-Sunset-A.jpg\",\"image\":\"${imageValue}\",\"video\":\"${videoValue}\",\"color\":\"#00ff00\",\"icon\":\"note\",\"action\":{\"type\":\"url\",\"value\":\"http://www.acoustic.com\"}}}"

        return bottomBannerString
    }

    fun sendInApp(context: Context, mapContent: HashMap<String, Any?>) {
        if(mapContent["content"] != null){
            val content = mapContent["content"] as HashMap<String, Any?>

            val duration = content["duration"]
            val orientation = content["orientation"]
            val mainImage = content["mainImage"]
            val color = content["color"]
            val foreground = content["foreground"]
            val icon = content["icon"]
            val text =  content["text"] 
            val title =  content["title"] 
            val image =  content["image"] 
            val video =  content["video"] 

            val action = content["action"] as HashMap<String, Any?>
            val type = action["type"]
            val value = action["value"]

            var triggerDate = mapContent["triggerDate"] as String
            triggerDate = triggerDate.dropLast(7)
            triggerDate +="+0000"

            var expirationDate = mapContent["expirationDate"] as String
            expirationDate = expirationDate.dropLast(7)
            expirationDate +="+0000"

            val maxViews = mapContent["maxViews"]
            val rules =  mapContent["rules"] as List<String>
            val template =  mapContent["template"] 

             var ruleString = ""
             rules.forEach{
                 ruleString += "\"$it\","
             }
            ruleString = ruleString.dropLast(1)

            var bottomBannerString = "{\"triggerDate\":\"${triggerDate}\",\"numViews\":0,\"maxViews\":${maxViews},\"rules\":[${ruleString}],\"template\":\"${template}\",\"views\":0,\"expirationDate\":\"${expirationDate}\","

            if(template == "default"){
                bottomBannerString +=  "\"content\":{\"duration\":\"${duration}\",\"text\":\"${text}\",\"mainImage\":\"${mainImage}\",\"color\":\"${color}\",\"icon\":\"${icon}\",\"action\":{\"type\":\"${type}\",\"value\":\"${value}\"}}}"
            } else if(template == "image"){
                bottomBannerString +=  "\"content\":{\"duration\":\"${duration}\",\"title\":\"${title}\",\"text\":\"${text}\",\"image\":\"${image}\",\"action\":{\"type\":\"${type}\",\"value\":\"${value}\"}}}"
            } else if(template == "video"){
                bottomBannerString +=  "\"content\":{\"duration\":\"${duration}\",\"title\":\"${title}\",\"text\":\"${text}\",\"video\":\"${video}\",\"action\":{\"type\":\"${type}\",\"value\":\"${value}\"}}}"
            }
           
            val extras2 = Bundle()
            extras2.putString("inApp", bottomBannerString)
            InAppManager.handleNotification(context, extras2, null, null)
        }  
    }

    fun createInApp(context: Context, bundle: Any, inAppType: Int) {
        val bundleJson = JSONObject.wrap(bundle);
        val stringBundleJson = bundleJson.toString().replace("\\","");
        val contentStringBundleJson = stringBundleJson.replace("templateContent","content")
        val finalStringBundleJson = contentStringBundleJson.replace("templateName","template")

        var cannedInAppStringBanner = ""

        when (inAppType) {
            0 -> cannedInAppStringBanner = createCannedInAppString("default", "123", "123ABC", "bottomBanner", "Bottom Banner Title")
            1 -> cannedInAppStringBanner = createCannedInAppString("default", "123", "123ABC", "topBanner", "Top Banner Title")
            2 -> cannedInAppStringBanner = createCannedInAppString("image", "123", "123ABC", "image", "Image Banner Title")
            3 -> cannedInAppStringBanner = createCannedInAppString("video", "123", "123ABC", "video", "Video Banner Title")
            else -> Log.i("TAG", "failed")
        }

        // 
        val extras2 = Bundle()
        extras2.putString("inApp", cannedInAppStringBanner)
        InAppManager.handleNotification(context, extras2, null, null)
    }

    fun deleteInApp(context: Context, inAppMessageId: String) {
        InAppManager.delete(context, inAppMessageId)
    }

    fun hideInApp(activity: Activity) {
        if (activity == null) {
            Logger.e(TAG, "Can't find activity")
            return
        }

        activity.runOnUiThread { internalHideInApp() }
    }

    fun displayView(activity: Activity) {
        val view = TextView(activity)
        view.textSize = 40f

        relativeLayout = RelativeLayout(activity)
        val scale: Float = activity.resources.displayMetrics.density
        val height = scale.toInt() * 500

        val viewLayout: RelativeLayout.LayoutParams = if (height > 0) {
            RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, height)
        } else {
            RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
        }
        viewLayout.addRule(RelativeLayout.ALIGN_PARENT_TOP)

        view.setBackgroundColor(Color.rgb(255, 255, 255))
        view.text = "Rendered on a native Android view"

        view.layoutParams = viewLayout

        relativeLayout!!.addView(view)
        val window: Window = activity.window
        val relativeLayoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        window.addContentView(relativeLayout, relativeLayoutParams)

        view.setOnClickListener {
            internalHideInApp()
        }
    }

    fun executeInApp(activity: Context, rules: List<String>) {

        registerInApp("video", "InAppVideo", 0)
        registerInApp("default", "InAppBanner", 44)
        registerInApp("image", "InAppImage", 0)

        if(activity == null) {
            Logger.e(TAG, "Can't find activity")
            return
        }

        val inAppMessage: InAppPayload? = InAppStorage.findFirst(activity, InAppStorage.KeyName.RULE, rules)

        if (inAppMessage == null) {
            Logger.d(TAG, "No inAppMessages to display for provided rules")
            sendEvent("NoInAppMessage", "")
            return
        }
        val messageBundle = convertInAppMessage(inAppMessage)

        val content = convertInAppMessage(inAppMessage)
        sendEvent("InAppMessage", content.toString())

        InAppStorage.updateMaxViews(activity, inAppMessage)
        if (inAppMessage.isFromPull) {
            InAppPlugin.updateInAppMessage(activity, inAppMessage)
        }
    }

    fun recordViewForInAppMessage(activity: Context, id: String?) {
         if(activity == null) {
            Logger.e(TAG, "Can't find activity")
            return
        }
        val inAppMessage: InAppPayload? = InAppStorage.getInappPayload(activity, id)
         if (inAppMessage == null) {
            Logger.d(TAG, "No inAppMessages for given id $id")
            return
        }
        InAppEvents.sendInAppMessageOpenedEvent(activity, inAppMessage)
    }

    fun syncInAppmessages(context: Context, result: MethodChannel.Result) {
        MessageSync.syncMessages(context, object : OperationCallback<MessageSync.SyncReport> {
            override fun onSuccess(p0: MessageSync.SyncReport?, p1: OperationResult?) {
            }

            override fun onFailure(p0: MessageSync.SyncReport?, p1: OperationResult?) {
                Log.e("InApp", " syncInAppmessages ~~~~~~ Failure")
            }
        })
    }

    fun registerInApp(template: String?, module: String?, height: Int) {
        inAppRegistry[template!!] = ModuleHeight(module!!, height)
    }

    fun clickInApp(context: Context, inAppMessageId: String?) {
        val inAppPayload = InAppStorage.getInappPayload(context, inAppMessageId) ?: return
        val content = inAppPayload.templateContent
        if (content == null) {
            Logger.e(TAG, "Can't find content")
            return
        }
        val action = content.getJSONObject("action")
        if (action == null) {
            Logger.e(TAG, "Can't find action")
            return
        }
        val actionType = action.getString("type")
        if (actionType == null) {
            Logger.e(TAG, "Can't find action type")
            return
        }
        val actionImpl =
            MceNotificationActionRegistry.getNotificationAction(context, actionType)
        if (actionImpl == null) {
            Logger.e(
                TAG,
                "Can't find a notification registered action for $actionType"
            )
            return
        }
        val eventAttributes: MutableList<Attribute> = LinkedList<Attribute>()
        eventAttributes.add(StringAttribute("actionTaken", actionType))
        val payload = HashMap<String, String>()
        val actionIterator = action.keys()
        while (actionIterator.hasNext()) {
            val key = actionIterator.next()
            val value = action.getString(key)
            payload[key] = value
            eventAttributes.add(StringAttribute(key, value))
        }
        actionImpl.handleAction(context, actionType, null, null, null, payload, false)
        var name = actionType
        val clickEventDetails = MceNotificationActionImpl.getClickEventDetails(actionType)
        if (clickEventDetails != null) {
            name = clickEventDetails.eventName
            eventAttributes.add(StringAttribute(clickEventDetails.valueName, action.toString()))
        }
        val event = Event("inAppMessage", name, Date(), eventAttributes, null, null)
        MceSdk.getQueuedEventsClient().sendEvent(context, event, true)
        InAppManager.delete(context, inAppMessageId)
    }

    private fun internalHideInApp() {
        if (relativeLayout != null) {
            val parent = relativeLayout!!.parent
            if (parent is ViewGroup) {
                parent.removeView(relativeLayout)
            } else {
                Logger.e(TAG, "InApp Parent is not a ViewGroup!")
            }
        }
        relativeLayout = null
    }

    private fun showInApp(inAppMessage: InAppPayload, activity: Activity, messenger: BinaryMessenger) {
        val messageBundle: Bundle = packageInAppMessage(inAppMessage)
        val template = inAppMessage.templateName
        val moduleHeight = inAppRegistry[template]
        if (moduleHeight == null) {
            Logger.e(
                TAG,
                "Can not find registered inapp template for $template"
            )
            return
        }
        relativeLayout = RelativeLayout(activity)
        relativeLayout!!.layoutParams =
            RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
        val scale: Float = activity.resources.displayMetrics.density
        val height = scale.toInt() * moduleHeight.height
        val viewLayout: RelativeLayout.LayoutParams = if (height > 0) {
            RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, height)
        } else {
            RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
        }
        val orientation = inAppMessage.templateContent.optString("orientation")
        if (orientation != null && orientation.toLowerCase() == "bottom") {
            viewLayout.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
        } else {
            viewLayout.addRule(RelativeLayout.ALIGN_PARENT_TOP)
        }
        val initialProperties = Bundle()
        initialProperties.putBundle("message", messageBundle)
        initialProperties.putFloat("containerHeight", moduleHeight.height.toFloat())
        initialProperties.putFloat("contentHeight", moduleHeight.height.toFloat())

        val view = TextView(activity)
        view.textSize = 72f
        view.setBackgroundColor(Color.rgb(33, 22, 11))
        view.text = "Rendered on a native Android view"
        view.layoutParams = viewLayout

        relativeLayout!!.addView(view)
        val window: Window = activity.window
        val relativeLayoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        window.addContentView(relativeLayout, relativeLayoutParams)
    }

    private fun convertInAppMessage(inAppMessage: InAppPayload): JSONObject {
        val message = JSONObject()
        message.put("inAppMessageId", inAppMessage.id)
        message.put("rules", inAppMessage.rules as ArrayList<String?>)
        message.put("expirationDate", inAppMessage.expirationDate.time.toFloat())
        message.put("triggerDate", inAppMessage.triggerDate.time.toFloat())
        message.put("templateName", inAppMessage.templateName)
        message.put("numViews", inAppMessage.views.toShort())
        message.put("maxViews", inAppMessage.maxViews.toShort())
        try {
            message.put("templateContent", inAppMessage.templateContent)
        } catch (ex: Exception) {
            Logger.e(TAG, "Couldn't translate template content", ex)
        }
        return message
    }

    private fun packageInAppMessage(inAppMessage: InAppPayload): Bundle {
        val message = Bundle()
        message.putString("inAppMessageId", inAppMessage.id)
        message.putStringArrayList("rules", inAppMessage.rules as ArrayList<String?>)
        message.putFloat("expirationDate", inAppMessage.expirationDate.time.toFloat())
        message.putFloat("triggerDate", inAppMessage.triggerDate.time.toFloat())
        message.putString("templateName", inAppMessage.templateName)
        message.putShort("numViews", inAppMessage.views.toShort())
        message.putShort("maxViews", inAppMessage.maxViews.toShort())
        try {
            val content: Bundle = convertJsonObjectToBundle(inAppMessage.templateContent)
            message.putBundle("content", content)
        } catch (ex: Exception) {
            Logger.e(TAG, "Couldn't translate template content", ex)
        }
        return message
    }

}