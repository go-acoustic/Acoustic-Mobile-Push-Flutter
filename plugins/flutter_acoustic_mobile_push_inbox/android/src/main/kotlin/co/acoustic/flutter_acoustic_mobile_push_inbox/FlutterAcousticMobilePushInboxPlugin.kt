package co.acoustic.flutter_acoustic_mobile_push_inbox

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import java.lang.Runnable
import android.util.Log
import android.view.ViewGroup
import android.view.Window
import android.widget.FrameLayout
import android.widget.RelativeLayout
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.FlutterAcousticSdkPushPlugin
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.convertFromJsontoHashMap
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.convertJsonObject
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.convertJsonObjectToBundle
import co.acoustic.mobile.push.sdk.api.OperationCallback
import co.acoustic.mobile.push.sdk.api.OperationResult
import co.acoustic.mobile.push.sdk.api.message.MessageSync
import co.acoustic.mobile.push.sdk.api.message.MessageSync.SyncReport
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationAction
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import co.acoustic.mobile.push.sdk.api.notification.NotificationDetails
import co.acoustic.mobile.push.sdk.events.EventsManager
import co.acoustic.mobile.push.sdk.plugin.inbox.InboxMessageProcessor
import co.acoustic.mobile.push.sdk.plugin.inbox.InboxMessageReference
import co.acoustic.mobile.push.sdk.plugin.inbox.RichContent
import co.acoustic.mobile.push.sdk.util.Logger
import io.flutter.app.FlutterApplication
import org.json.JSONArray
import org.json.JSONObject
import java.lang.Exception
import co.acoustic.mobile.push.sdk.plugin.inbox.RichContentDatabaseHelper
import co.acoustic.mobile.push.sdk.events.EventsManager.sendEvent
import co.acoustic.mobile.push.sdk.plugin.inbox.InboxMessagesClient
import co.acoustic.mobile.push.sdk.plugin.inbox.RichContentDatabaseHelper.MessageCursor
import co.acoustic.mobile.push.sdk.api.MceSdk
import co.acoustic.mobile.push.sdk.api.attribute.Attribute
import co.acoustic.mobile.push.sdk.api.attribute.StringAttribute
import co.acoustic.mobile.push.sdk.api.event.Event
import co.acoustic.mobile.push.sdk.notification.MceNotificationActionImpl
import co.acoustic.mobile.push.sdk.notification.MceNotificationActionImpl.ClickEventDetails
import java.util.*
import kotlin.collections.HashMap

import io.flutter.plugin.common.BinaryMessenger
import androidx.annotation.NonNull
import androidx.annotation.UiThread
import co.acoustic.mobile.push.sdk.plugin.inbox.InboxEvents
import co.acoustic.mobile.push.sdk.notification.ActionImpl







/** FlutterAcousticMobilePushInboxPlugin  */
class FlutterAcousticMobilePushInboxPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    companion object {
        @JvmStatic
        private val TAG = "AcousticInboxPlugin"

        @JvmStatic
        private var result: Result? = null

        @JvmStatic
        private var methodCall: MethodCall? = null
        
        @JvmStatic
            private var binaryMessenger: BinaryMessenger? = null


        @JvmStatic
        fun sendEvent(methodName: String, any: Any?) {

            Handler(Looper.getMainLooper()).post({

                try {
                    MethodChannel(binaryMessenger, "flutter_acoustic_mobile_push_inbox")
                            .invokeMethod(methodName,any)
                } catch (ex: Exception) {
                    Log.e("Exception sendEvent", "${ex.localizedMessage}", ex)
                }

            })
        
        }

        @JvmStatic
        private val LocationAuthorization = "LocationAuthorization"

        @JvmStatic
        private val Registered = "Registered"
        private val InboxCountUpdate = "InboxCountUpdate"
        private val SyncInbox = "SyncInbox"


        private lateinit var mContext : Context
        private lateinit var mActivity : Activity
        private lateinit var channel : MethodChannel

        var channelDescription = "This is the notification channel for the MCE Inbox plugin"
        var channelName: CharSequence = "MCE Inbox Notification Channel"
        var channelIdentifier = "mce_inbox_channel"
    }

        private val TYPE = "openInboxMessage"
        private val TAG = "AcousticInBoxModule"
        lateinit var context: Context
        lateinit var activity: Activity
        private var relativeLayout: RelativeLayout? = null
        private var inboxActionModule: String? = null
        private var channel: MethodChannel? = null

        override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
            mContext = flutterPluginBinding.applicationContext
            binaryMessenger = flutterPluginBinding.binaryMessenger

            channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "flutter_acoustic_mobile_push_inbox")
            channel!!.setMethodCallHandler(FlutterAcousticMobilePushInboxPlugin())
        }

    

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        FlutterAcousticMobilePushInboxPlugin.result = result
        FlutterAcousticMobilePushInboxPlugin.methodCall = call
        when(call.method) {

            "syncInboxMessage" -> {
                syncInboxMessages(mContext, result)
            }
            "deleteInboxMessage" -> {
                deleteInboxMessage(mContext, call.arguments.toString())
            }
            "readInboxMessage" -> {
                readInboxMessage(mContext, call.arguments.toString())
            }
            "unreadInboxMessage" -> {
                unreadInboxMessage(mContext, call.arguments.toString())
            }
            "inboxMessageCount" -> {
                inboxMessageCount(mContext)
            }
            "registerInboxComponent" -> {
                registerInboxComponent(mContext)
            }
              "clickInboxAction" -> {         
                clickInboxAction(mContext, JSONObject(call.argument<String>("action")), call.argument<String>("inboxMessageId"))
            }

            else -> {

            }
        }

       
    }

   override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel!!.setMethodCallHandler(null)
    }

    fun registerInboxComponent(context: Context) {
        MceNotificationActionRegistry.registerNotificationAction(context, TYPE, object : MceNotificationAction {

            override fun handleAction(
                thisContext: Context?, type: String?, name: String?, attribution: String?,
                mailingId: String?, payload: MutableMap<String, String>?, fromNotification: Boolean) {
 

                val messageReference = InboxMessageReference(payload?.get("value"), payload?.get(
                    InboxMessageReference.INBOX_MESSAGE_ID_KEY))
                if (messageReference.hasReference()) {
                    val inboxMessage = messageReference.getMessageFromDb(thisContext)

                    if (inboxMessage == null) {
                        InboxMessageProcessor.addMessageToLoad(messageReference)


                        val intent = Intent("co.acoustic.flutter.openInboxMessage")
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        messageReference.addToIntent(intent)
                        context.startActivity(intent)
                        if (fromNotification) {
                            InboxEvents.sendInboxNotificationOpenedEvent(context, ActionImpl(type, name, payload), attribution, mailingId);
                        }

                    } 
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
                return false
            }

        })
    }

    fun hideInbox(activity: Activity) {
        if (activity == null) {
            Logger.e(TAG, "Can't find activity")
            return
        }
        activity.runOnUiThread { internalHideInbox() }
    }

    fun inboxMessageCount(context: Context) {
        val messageCursor =
            RichContentDatabaseHelper.getRichContentDatabaseHelper(context).messages
        var messages = 0
        var unread = 0
        while (messageCursor.moveToNext()) {
            val message = messageCursor.richContent
            messages++
            if (!message.isRead) {
                unread++
            }
        }
        val map = JSONObject()
        map.put("messages", messages)
        map.put("unread", unread)

        sendEvent("InBoxMessageCount",map.toString())
    }

    fun deleteInboxMessage(context: Context, inboxMessageId: String?) {
        InboxMessagesClient.deleteMessageById(context, inboxMessageId)
    }

    fun readInboxMessage(context: Context, inboxMessageId: String?) {
         val messageCursor =
            RichContentDatabaseHelper
            .getRichContentDatabaseHelper(context)
            .getMessagesByMessageId(inboxMessageId)
        Log.i("Inbox", "GET MESSAGE BY MESSAGE ID COUNT = ${messageCursor.count}")
        if (messageCursor.count == 1) {
            messageCursor.moveToFirst()
            val richContent = messageCursor.richContent
            richContent.isRead = true
            InboxEvents.sendInboxMessageOpenedEvent(context, richContent)
        }
        InboxMessagesClient.setMessageReadById(context, inboxMessageId)
    }

    fun unreadInboxMessage(context: Context, inboxMessageId: String?) {
         val messageCursor =
            RichContentDatabaseHelper
            .getRichContentDatabaseHelper(context)
            .getMessagesByMessageId(inboxMessageId)
        Log.i("Inbox", "GET MESSAGE BY MESSAGE ID COUNT = ${messageCursor.count}")
        if (messageCursor.count == 1) {
            messageCursor.moveToFirst()
            val richContent = messageCursor.richContent
            richContent.isRead = false
        }
        InboxMessagesClient.setMessageUnreadById(context, inboxMessageId)
    }

    fun syncInboxMessages(context: Context, channelResult: MethodChannel.Result) {
        MessageSync.syncMessages(context, object : OperationCallback<SyncReport?> {
            override fun onSuccess(syncReport: SyncReport?, result: OperationResult?) {
                Log.e("Inbox", "syncInboxMessages ~~~~~~ onSuccess")

                listInboxMessages(context, true)
            }

            override fun onFailure(syncReport: SyncReport?, result: OperationResult?) {
                Log.e("Inbox", "syncInboxMessages ~~~~~~ onFailure")

                listInboxMessages(context, true)
            }
        })
    }

    fun listInboxMessages(context: Context, direction: Boolean) {
        val messages = JSONArray()
        val messageCursor =
            RichContentDatabaseHelper.getRichContentDatabaseHelper(context).messages
        while (messageCursor.moveToNext()) {
            val message = messageCursor.richContent
            val messageMap = JSONObject()
            messageMap.put("inboxMessageId", message.messageId)
            messageMap.put("richContentId", message.contentId)
            messageMap.put("templateName", message.template)
            messageMap.put("attribution", message.attribution)
            messageMap.put("mailingId", message.messageId)
            messageMap.put("sendDate", message.sendDate.time)
            messageMap.put("expirationDate", message.expirationDate.time)
            messageMap.put("isDeleted", message.isDeleted)
            messageMap.put("isRead", message.isRead)
            messageMap.put("isExpired", message.isExpired)
            try {
                val content = message.content
                if (content != null) {
                    messageMap.put("content", content)
                }
            } catch (ex: Exception) {
                Logger.d(TAG, "Couldn't convert inbox json content", ex)
            }
            messages.put(messageMap)
        }

        Log.e("InBox", "${messages.length()}")
        if (messages.length() > 0) {
            sendEvent("InboxMessages",messages.toString())
        } else {
            sendEvent("InboxMessages","")
        }

    }

    fun clickInboxAction(context: Context, action: JSONObject, inboxMessageId: String?) {

        val messageCursor = RichContentDatabaseHelper.getRichContentDatabaseHelper(context)
            .getMessagesByMessageId(inboxMessageId)
        messageCursor.moveToFirst()
        val message = messageCursor.richContent
        val richContentId = message.contentId
        val attribution = message.attribution

        // get richContentId and attribution
        // put in event
        val actionType: String = action.getString("type")
        val actionImpl =
            MceNotificationActionRegistry.getNotificationAction(context, actionType)
        if (actionImpl != null) {


            val payload: HashMap<String, String> = convertFromJsontoHashMap(action)
            actionImpl.handleAction(context, actionType, null, null, null, payload, false)
            val eventAttributes: MutableList<Attribute> = LinkedList<Attribute>()
            eventAttributes.add(StringAttribute("richContentId", richContentId))
            eventAttributes.add(StringAttribute("inboxMessageId", inboxMessageId))
            eventAttributes.add(StringAttribute("actionTaken", actionType))
            var name = actionType
            val clickEventDetails = MceNotificationActionImpl.getClickEventDetails(actionType)
            if (clickEventDetails != null) {
                name = clickEventDetails.eventName
                val value = payload["value"]
                eventAttributes.add(StringAttribute(clickEventDetails.valueName, value))
            } else {
                for (key in payload.keys) {
                    eventAttributes.add(
                        StringAttribute(
                            key,
                            payload[key]
                        )
                    )
                }
            }
            val event = Event("inboxMessage", name, Date(), eventAttributes, attribution, null)
            MceSdk.getEventsClient(false)
                .sendEvent(context, event, object : OperationCallback<Event?> {
                    override fun onSuccess(event: Event?, result: OperationResult) {}
                    override fun onFailure(event: Event?, result: OperationResult) {
                        MceSdk.getQueuedEventsClient().sendEvent(context, event)
                    }
                })
        }
    }


    private fun internalHideInbox() {
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

    private fun showInboxMessage(inboxMessage: RichContent, activity: Activity) {
        if (inboxActionModule == null) {
            Logger.e(TAG, "inbox action module is not registered")
            return
        }

        relativeLayout = RelativeLayout(context)
        relativeLayout!!.layoutParams =
            RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
        val viewLayout = RelativeLayout.LayoutParams(
            RelativeLayout.LayoutParams.MATCH_PARENT,
            RelativeLayout.LayoutParams.MATCH_PARENT
        )

        viewLayout.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)

        val application: FlutterApplication = activity.application as FlutterApplication


        val messageBundle = Bundle()
        messageBundle.putLong("sendDate", inboxMessage.sendDate.time)
        messageBundle.putLong("expirationDate", inboxMessage.expirationDate.time)
        messageBundle.putBoolean("isDeleted", inboxMessage.isDeleted)
        messageBundle.putBoolean("isRead", inboxMessage.isRead)
        messageBundle.putBoolean("isExpired", inboxMessage.isExpired)
        messageBundle.putString("templateName", inboxMessage.template)
        messageBundle.putString("attribution", inboxMessage.attribution)
        messageBundle.putString("mailingId", inboxMessage.messageId)
        messageBundle.putString("inboxMessageId", inboxMessage.messageId)
        messageBundle.putString("richContentId", inboxMessage.contentId)

        try {
            val content = inboxMessage.content
            if (content != null) {
                messageBundle.putBundle("content", convertJsonObjectToBundle(content))
            }
        } catch (ex: Exception) {
            Logger.d(TAG, "Couldn't convert inbox json content", ex)
        }

        val initialProperties = Bundle()
        initialProperties.putBundle("message", messageBundle)

        val window: Window = activity.window
        val relativeLayoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.FILL_PARENT
        )
        window.addContentView(relativeLayout, relativeLayoutParams)
    }
}