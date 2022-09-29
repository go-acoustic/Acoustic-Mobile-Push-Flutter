package co.acoustic.flutter_acoustic_mobile_push_geofence

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.location.Location
import android.util.Log
import co.acoustic.mobile.push.sdk.location.LocationManager
import co.acoustic.mobile.push.sdk.location.LocationsDatabaseHelper
import co.acoustic.mobile.push.sdk.location.LocationsDatabaseHelper.LocationCursor
import co.acoustic.mobile.push.sdk.location.MceLocation
import org.json.JSONArray
import org.json.JSONObject
import io.flutter.plugin.common.BinaryMessenger
import androidx.annotation.NonNull
import androidx.annotation.UiThread
import android.app.Activity
import androidx.core.app.ActivityCompat

/** FlutterAcousticMobilePushGeofencePlugin  */
class FlutterAcousticMobilePushGeofencePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "flutter_acoustic_mobile_push_geofence")
        channel.setMethodCallHandler(FlutterAcousticMobilePushGeofencePlugin())

        binaryMessenger = flutterPluginBinding.binaryMessenger
        mContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        FlutterAcousticMobilePushGeofencePlugin.result = result
        FlutterAcousticMobilePushGeofencePlugin.methodCall = call

        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "geofencesNearCoordinate" -> {
                val arguments = JSONObject(call.arguments.toString())
                geofencesNearCoordinate(
                        mContext, arguments.getDouble("latitude"),
                        arguments.getDouble("longitude"),
                        arguments.getInt("radius"), result)
            }
            "sendLocationPermission" -> {
                LocationManager.enableLocationSupport(mContext)
                result.success("Enabled")
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel!!.setMethodCallHandler(null)
    }

    fun geofencesNearCoordinate(
        context: Context,
        latitude: Double,
        longitude: Double,
        radius: Int, result: MethodChannel.Result
    ) {

        val location = Location("SDK")
        location.latitude = latitude
        location.longitude = longitude

        if (location.latitude == 0.0) location.latitude = 37.33233141
        if (location.longitude == 0.0) location.longitude = -122.0312186

        val geofenceList = JSONArray()

        val locationsDatabaseHelper: LocationsDatabaseHelper =
            LocationsDatabaseHelper.geGeofencesDatabaseHelper(context)
        val relevantGeofences: LocationManager.LocationsSearchResult =
            LocationManager.findLocations(location, 1000, locationsDatabaseHelper)

        var locations = LocationManager.getAllLocations(context)

        for (location in locations) {

            val geofenceMap = JSONObject()
            geofenceMap.put("id", location.id.toString())
            geofenceMap.put("latitude", location.latitude.toDouble())
            geofenceMap.put("longitude", location.longitude.toDouble())
            geofenceMap.put("radius", location.radius.toDouble())
            geofenceList.put(geofenceMap)
        }

   
        result.success(geofenceList.toString())
  
        
    }
    companion object {
        @JvmStatic
        private val TAG = "AcousticGeofencePlugin"

        @JvmStatic
        private var binaryMessenger: BinaryMessenger? = null

        @JvmStatic
        private var result: Result? = null

        @JvmStatic
        private var methodCall: MethodCall? = null

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
                MethodChannel(binaryMessenger, "flutter_acoustic_mobile_push_geofence")
                        .invokeMethod(methodName,any)
            } catch (ex: Exception) {
                Log.e("Exception sendEvent", "${ex.localizedMessage}")
            }
        }

        @JvmStatic
        private val LocationAuthorization = "LocationAuthorization"

        @JvmStatic
        private val EnteredGeofence = "EnteredGeofence"
        private val ExitedGeofence = "ExitedGeofence"

        private lateinit var mContext : Context
        private lateinit var channel : MethodChannel

        var channelDescription = "This is the notification channel for the MCE Geofence plugin"
        var channelName: CharSequence = "MCE Geofence Notification Channel"
        var channelIdentifier = "mce_geofence_channel"

    }
}