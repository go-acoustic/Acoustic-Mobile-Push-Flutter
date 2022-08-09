package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push


import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import co.acoustic.mobile.push.sdk.Preferences
import co.acoustic.mobile.push.sdk.registration.RegistrationClientImpl

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import co.acoustic.mobile.push.sdk.messaging.MessagingManager
import co.acoustic.mobile.push.sdk.SdkPreferences
import co.acoustic.mobile.push.sdk.SdkTags
import co.acoustic.mobile.push.sdk.SdkTags.TAG_BEACON
import co.acoustic.mobile.push.sdk.SdkTags.TAG_LOCATION
import co.acoustic.mobile.push.sdk.SdkTags.TAG_SDK_LIFECYCLE_INIT
import co.acoustic.mobile.push.sdk.SdkTags.TAG_SDK_LIFECYCLE
import co.acoustic.mobile.push.sdk.api.MceSdkConfiguration.DatabaseConfiguration
import co.acoustic.mobile.push.sdk.api.MceSdkConfiguration.LocationConfiguration.IBeaconConfiguration
import co.acoustic.mobile.push.sdk.api.MceSdkConfiguration.LocationConfiguration.SyncConfiguration
import co.acoustic.mobile.push.sdk.beacons.MceBluetoothScanner
import co.acoustic.mobile.push.sdk.location.LocationPreferences
import co.acoustic.mobile.push.sdk.wi.MceSdkWakeLock
import co.acoustic.mobile.push.sdk.location.LocationManager
import co.acoustic.mobile.push.sdk.location.LocationPreferences.LocationsState
import co.acoustic.mobile.push.sdk.util.Logger
import org.json.JSONException
import org.json.JSONObject
import android.content.SharedPreferences
import android.content.SharedPreferences.Editor
import android.os.Build
import android.os.Bundle
import co.acoustic.mobile.push.sdk.api.*
import android.os.Environment
import androidx.annotation.RequiresApi
import androidx.annotation.UiThread
import java.lang.Exception
import co.acoustic.mobile.push.sdk.job.MceJobManager.restart
import co.acoustic.mobile.push.sdk.db.DbAdapter
import co.acoustic.mobile.push.sdk.encryption.EncryptionPreferences
import co.acoustic.mobile.push.sdk.api.SdkState
import co.acoustic.mobile.push.sdk.api.MceSdk
import co.acoustic.mobile.push.sdk.api.attribute.Attribute
import co.acoustic.mobile.push.sdk.plugin.Plugin
import co.acoustic.mobile.push.sdk.plugin.PluginRegistry
import co.acoustic.mobile.push.sdk.registration.PhoneHomeManager
import co.acoustic.mobile.push.sdk.api.message.MessageProcessorRegistry
import co.acoustic.mobile.push.sdk.api.message.MessageProcessor
import co.acoustic.mobile.push.sdk.notification.CertificationMessageProcessor
import co.acoustic.mobile.push.sdk.apiinternal.MceSdkInternal
import co.acoustic.mobile.push.sdk.api.attribute.StringAttribute
import java.util.*
import co.acoustic.mobile.push.sdk.util.AssetsUtil
import com.google.android.gms.security.ProviderInstaller
import co.acoustic.mobile.push.sdk.job.MceJobManager.restart
import co.acoustic.mobile.push.sdk.api.MceSdkConfiguration
import co.acoustic.mobile.push.sdk.api.SdkInitLifecycleCallbacks
import co.acoustic.mobile.push.sdk.api.MceApplication
import co.acoustic.mobile.push.sdk.api.message.MessageSync
import co.acoustic.mobile.push.sdk.job.MceJobManager
import co.acoustic.mobile.push.sdk.location.MceGeofence
import co.acoustic.mobile.push.sdk.notification.NotificationsUtility
import co.acoustic.mobile.push.sdk.session.SessionManager
import co.acoustic.mobile.push.sdk.session.SessionTrackingTask
import co.acoustic.mobile.push.sdk.task.MceSdkTaskScheduler
import co.acoustic.mobile.push.sdk.util.Iso8601
import com.google.firebase.FirebaseApp
import io.flutter.plugin.common.BinaryMessenger
import org.json.JSONArray
import kotlin.collections.ArrayList

import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.customAction.AcousticCustomActionModule
import co.acoustic.flutter.sdk.flutter_acoustic_mobile_push.event.AcousticEventModule

import co.acoustic.mobile.push.sdk.location.LocationBroadcastReceiver

/** FlutterAcousticSdkPushPlugin */
class FlutterAcousticSdkPushPlugin: ActivityAware, FlutterPlugin, MethodCallHandler, io.flutter.plugin.common.PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  companion object {
    @JvmStatic
    private val TAG = "AcousticSdkPlugin"

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
        MethodChannel(binaryMessenger, "flutter_acoustic_mobile_push")
          .invokeMethod(methodName,any)
      } catch (ex: Exception) {
        Log.e("Exception sendEvent", "${ex.localizedMessage}")
      }
    }

    @JvmStatic
    private val LocationAuthorization = "LocationAuthorization"

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

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    binaryMessenger = flutterPluginBinding.binaryMessenger
    mContext = flutterPluginBinding.applicationContext
    FirebaseApp.initializeApp(mContext)

    // createNotificationChannel()

    channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "flutter_acoustic_mobile_push")
    channel.setMethodCallHandler(FlutterAcousticSdkPushPlugin())

    resume()
    RegistrationClientImpl.markSdkAsInitiated(mContext)
    SDKHandler.setup(mContext)


    Log.d("TAG, MAIN" , "PLUGIN MAIN PLUGIN: onAttachedToEngine")

  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    FlutterAcousticSdkPushPlugin.result = result
    FlutterAcousticSdkPushPlugin.methodCall = call

    when (call.method) {

      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "register" -> {
        RegistrationClientImpl.markSdkAsInitiated(mContext)
        SDKHandler.setup(mContext)
      }
      "registerCustomAction" -> {
        AcousticCustomActionModule.registerAction(mContext, call.arguments.toString(), result)
      }
      "unregisterCustomAction" -> {
        AcousticCustomActionModule.unregisterAction(mContext, call.arguments.toString(), result)
      }
      "sentEvents" -> {
        MceSdk.getQueuedEventsClient().sendEvent(mContext, null, true)
      }
      "updateUserAttributes" -> {
       AcousticEventModule.updateUserAttributesList(mContext, call.arguments as List<*>)
      }
      "deleteUserAttributes" -> {
        AcousticEventModule.deleteUserAttributesList(mContext, call.arguments as List<String>)
      }
      "sendEvents" -> {
        AcousticEventModule.createEvent(mContext, call.arguments as Map<String, String>)
      }
      "showCalendar" -> {

      }
      "showDial" -> {

      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
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

  @RequiresApi(Build.VERSION_CODES.O)
  private fun createNotificationChannel() {
    val notificationManager =
      mContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    var channel = notificationManager.getNotificationChannel(channelIdentifier)
    if (channel == null) {
      val importance = NotificationManager.IMPORTANCE_HIGH
      channel = NotificationChannel(channelIdentifier, channelName, importance)
      channel.description = channelDescription
      channel.setShowBadge(true)
      val notificationsPreference = MceSdk.getNotificationsClient().notificationsPreference
      notificationsPreference.setNotificationChannelId(mContext, channelIdentifier)
      notificationManager.createNotificationChannel(channel)
    }
  }

  private fun resume() {
    NotificationsUtility.checkOsNotificationsStatus(mContext)
    MceJobManager.validateJobs(mContext)

    if (SdkPreferences.isSessionServiceActivated(mContext)) {
      Logger.d(TAG, "Deactivating session tracking service")
      MceSdkTaskScheduler.cancelQueuedTask(mContext, SessionTrackingTask.getInstance())
      SdkPreferences.setSessionServiceActivated(mContext, false)
    }
    var sessionState = SessionManager.getSessionState(mContext)
    if (SdkPreferences.isSessionTrackingEnabled(mContext)) {
      val sessionTimeout = SdkPreferences.getSessionDuration(mContext)
      val now = Date()
      if (sessionState.sessionStartDate != null) {
        if (sessionState.sessionEndDate != null) {
          SessionManager.endSession(mContext, sessionState, now)
        } else {
          val lastResumeTime = SdkPreferences.getLastResumeTime(mContext)
          if (lastResumeTime != null && now.time - lastResumeTime.time > sessionTimeout) {
            sessionState =
              SessionManager.SessionState(
                lastResumeTime,
                Date(lastResumeTime.time + sessionTimeout)
              )
            SessionManager.endSession(mContext, sessionState, now)
          } else {
            SdkPreferences.setLastResumeTime(mContext, now)
            SdkPreferences.setLastPauseTime(mContext, null)
          }
        }
      } else {
        SessionManager.startSession(mContext, now)
      }
    } else {
      if (sessionState.sessionStartDate != null && sessionState.sessionEndDate != null) {
        SessionManager.endSession(mContext, sessionState, null)
      }
    }
    Logger.d(TAG, "SDK onResume end")
  }
}
