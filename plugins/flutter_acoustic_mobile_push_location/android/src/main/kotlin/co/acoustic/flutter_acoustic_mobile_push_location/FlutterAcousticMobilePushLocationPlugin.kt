package co.acoustic.flutter_acoustic_mobile_push_location

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.ContextWrapper
import android.content.SharedPreferences
import androidx.core.app.ActivityCompat
import co.acoustic.mobile.push.sdk.location.LocationManager
import co.acoustic.mobile.push.sdk.location.LocationRetrieveService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.BinaryMessenger
import android.util.Log
import androidx.annotation.NonNull
import java.util.*
import androidx.annotation.RequiresApi
import androidx.annotation.UiThread
import android.app.NotificationChannel
import android.app.NotificationManager
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class FlutterAcousticMobilePushLocationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, io.flutter.plugin.common.PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will be the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    companion object {
        @JvmStatic
        private val TAG = "AcousticLocationPlugin"

        @JvmStatic
        private var result: Result? = null

        @JvmStatic
        private var methodCall: MethodCall? = null

        @JvmStatic
        private var binaryMessenger: BinaryMessenger? = null
 
        @JvmStatic
        private val LocationAuthorization = "LocationAuthorization"

        @JvmStatic
        private val DownloadedLocations = "DownloadedLocations"
        private val Registered = "Registered"
        private val RegistrationChanged = "RegistrationChanged"

        private lateinit var mContext : Context
        private lateinit var mActivity : Activity
        private lateinit var channel : MethodChannel

        var channelDescription = "This is the notification channel for the MCE Location Plugin"
        var channelName: CharSequence = "MCE Location Channel"
        var channelIdentifier = "mce_location_channel"

        @JvmStatic
        @UiThread
        fun sendEvent(methodName: String, any: Any?) {
          try {
            MethodChannel(binaryMessenger, "flutter_acoustic_mobile_push")
              .invokeMethod(methodName,any)
          } catch (ex: Exception) {
            Log.e("Exception sendEvent", "${ex.localizedMessage}")
          }
        }
    }

    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        mContext = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "flutter_acoustic_mobile_push_location")
        channel!!.setMethodCallHandler(FlutterAcousticMobilePushLocationPlugin())
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        FlutterAcousticMobilePushLocationPlugin.result = result
        FlutterAcousticMobilePushLocationPlugin.methodCall = call

        when (call.method) {
            "checkLocationPermission" -> {
                this.locationStatus(mContext, result)
            }
            "syncLocations" -> {
                this.syncLocations(mContext)
            }
            "getLocationPermission"-> {
                this.enableLocation(mContext, mActivity, result)
            }
        }
    }

  fun locationStatus(context: Context, result: MethodChannel.Result) {
            val prefs: SharedPreferences =
                context.getSharedPreferences("MCE", Context.MODE_PRIVATE)
            val status = prefs.getBoolean("locationInitialized", false)
            if (status != null) {
                val access = ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.ACCESS_FINE_LOCATION
                )
                if (access == PackageManager.PERMISSION_GRANTED) {
                    result.success("always")
                } else {
                   result.success("denied")
                }
            } else {
               result.success("disabled")
            }
        }

    fun syncLocations(context: Context) {
        LocationRetrieveService.startLocationUpdates(context, false)
    }

    fun enableLocation(context: Context, activity: Activity, result: MethodChannel.Result) {
        val prefs: SharedPreferences =
            context.getSharedPreferences("MCE", Context.MODE_PRIVATE)
        val prefEditor = prefs.edit()
        prefEditor.putBoolean("locationInitialized", true)
        prefEditor.commit()
        if (activity != null) {
            activity.runOnUiThread {
                if (ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(
                            Manifest.permission.ACCESS_FINE_LOCATION,
                            Manifest.permission.ACCESS_COARSE_LOCATION
                        ),
                        0
                    )
                } else {
                    LocationManager.enableLocationSupport(context)
                    result.success(true)
                }
            }
        }
    }

    fun enableLocationTest(context: Context) {
        LocationManager.enableLocationSupport(context)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(p0: ActivityPluginBinding) {
        mActivity = p0.activity
        p0.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
        mActivity = p0.activity
    }

    override fun onDetachedFromActivity() {
    }

    override fun onActivityResult(p0: Int, p1: Int, p2: Intent?): Boolean {
        return true
    }
}