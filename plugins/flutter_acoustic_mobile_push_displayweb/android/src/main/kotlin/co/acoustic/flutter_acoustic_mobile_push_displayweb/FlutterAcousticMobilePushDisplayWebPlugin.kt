package co.acoustic.flutter_acoustic_mobile_push_displayweb;
import android.app.Activity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.content.Intent
import android.os.Bundle
import co.acoustic.flutter_acoustic_mobile_push_displayweb.DisplayWebViewActivity
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationAction
import co.acoustic.mobile.push.sdk.api.notification.NotificationDetails
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import androidx.annotation.NonNull

import org.json.JSONObject
import io.flutter.plugin.common.BinaryMessenger

/** FlutterAcousticMobilePushDisplaywebPlugin  */
class FlutterAcousticMobilePushDisplayWebPlugin : FlutterPlugin, MethodCallHandler, MceNotificationAction {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    companion object {
        @JvmStatic
        private val TAG = "AcousticDisplayWeb"

        @JvmStatic
        private var result: Result? = null

        @JvmStatic
        private var binaryMessenger: BinaryMessenger? = null
    }

        private lateinit var mContext : Context
        private lateinit var mActivity : Activity
        private lateinit var channel : MethodChannel

        private url: String = ""

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        binaryMessenger = flutterPluginBinding.binaryMessenger
        mContext = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "flutter_acoustic_mobile_push_displayweb")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method.equals("displayWebAction")) {
            url = call.arguments as String
            MceNotificationActionRegistry.registerNotificationAction(mContext, "displayWeb", FlutterAcousticMobilePushDisplayWebPlugin())
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun handleAction(
        context: Context?,
        type: String?,
        name: String?,
        attributionp3: String?,
        mailingId: String?,
        payload: MutableMap<String, String>?,
        fromNotification: Boolean
    ) {
        val it = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
        context!!.sendBroadcast(it)
        val intent = Intent(context, DisplayWebViewActivity::class.java)
        intent.putExtra("url", url)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
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
}