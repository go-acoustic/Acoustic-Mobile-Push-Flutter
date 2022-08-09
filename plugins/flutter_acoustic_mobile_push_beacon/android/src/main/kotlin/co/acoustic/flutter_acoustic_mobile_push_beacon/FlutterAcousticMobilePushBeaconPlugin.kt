package co.acoustic.flutter_acoustic_mobile_push_beacon

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.FlutterAcousticSdkPushPlugin
import co.acoustic.mobile.push.sdk.beacons.IBeacon
import co.acoustic.mobile.push.sdk.beacons.IBeaconsPreferences
import co.acoustic.mobile.push.sdk.location.LocationApi
import co.acoustic.mobile.push.sdk.location.LocationManager
import co.acoustic.mobile.push.sdk.location.LocationPreferences
import org.json.JSONArray
import org.json.JSONObject
import java.lang.Exception
import java.util.*
import co.acoustic.flutter_acoustic_mobile_push_beacon.MainActivity
import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger
import androidx.annotation.UiThread
import android.content.SharedPreferences
import androidx.core.app.ActivityCompat
import android.Manifest
import android.content.pm.PackageManager

import androidx.core.content.ContextCompat

/** FlutterAcousticMobilePushBeaconPlugin */
class FlutterAcousticMobilePushBeaconPlugin: FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    override fun onAttachedToEngine(@NonNull p0: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(p0.getBinaryMessenger(), "flutter_acoustic_mobile_push_beacon")
        channel.setMethodCallHandler(FlutterAcousticMobilePushBeaconPlugin())

        mContext = p0.applicationContext
        binaryMessenger = p0.binaryMessenger
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        FlutterAcousticMobilePushBeaconPlugin.result = result
        FlutterAcousticMobilePushBeaconPlugin.methodCall = call

        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "getIBeaconLocations" -> {
                FlutterAcousticMobilePushBeaconPlugin.beaconRegions(mContext, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull p0: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
         @JvmStatic
        @UiThread
        fun sendEvent(methodName: String, any: Any?) {
            try {
                MethodChannel(binaryMessenger, "flutter_acoustic_mobile_push_beacon")
                        .invokeMethod(methodName,any)
            } catch (ex: Exception) {
                Log.e("Exception sendEvent", "${ex.localizedMessage}")
            }
        }

        fun beaconRegions(context: Context, @NonNull result: MethodChannel.Result) {
            sendEvent("UUID", IBeaconsPreferences.getBeaconsUUID(context))
            val beaconList = JSONArray()
           var locations = LocationManager.getAllLocations(context)
            for (location in locations) {
                try {
                    val beaconLocation: IBeacon = location as IBeacon
                    val beacon = JSONObject()
                    beacon.put("major", beaconLocation.major)
                    beacon.put("minor", beaconLocation.minor)
                    beacon.put("id", beaconLocation.id)
                    beaconList.put(beacon)

                } catch (ex: Exception) {
                    Log.e("Exception -->", ex.localizedMessage)
                }
            }
            if (beaconList.length() > 0) {
                result.success(beaconList.toString())
            } 
        }

        @JvmStatic
        private val TAG = "AcousticBeaconPlugin"

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
        private val EnteredBeacon = "EnteredBeacon"
        private val ExitedBeacon = "ExitedBeacon"


        private lateinit var mContext : Context
        private lateinit var mActivity : Activity
        private lateinit var channel : MethodChannel

        var channelDescription = "This is the notification channel for the MCE Beacon plugin"
        var channelName: CharSequence = "MCE Beacon Notification Channel"
        var channelIdentifier = "mce_beacon_channel"

    }
}