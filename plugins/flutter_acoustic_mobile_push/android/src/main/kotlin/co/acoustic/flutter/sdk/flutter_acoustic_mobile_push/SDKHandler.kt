package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.os.Environment
import android.util.Log
import co.acoustic.mobile.push.sdk.Preferences
import co.acoustic.mobile.push.sdk.SdkPreferences
import co.acoustic.mobile.push.sdk.SdkTags
import co.acoustic.mobile.push.sdk.api.*
import co.acoustic.mobile.push.sdk.api.message.MessageProcessorRegistry
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import co.acoustic.mobile.push.sdk.beacons.IBeaconsPreferences
import co.acoustic.mobile.push.sdk.beacons.MceBluetoothScanner
import co.acoustic.mobile.push.sdk.db.DbAdapter
import co.acoustic.mobile.push.sdk.encryption.EncryptionPreferences
import co.acoustic.mobile.push.sdk.location.LocationBroadcastReceiver
import co.acoustic.mobile.push.sdk.location.LocationManager
import co.acoustic.mobile.push.sdk.location.LocationPreferences
import co.acoustic.mobile.push.sdk.messaging.MessagingManager
import co.acoustic.mobile.push.sdk.notification.CertificationMessageProcessor
import co.acoustic.mobile.push.sdk.plugin.Plugin
import co.acoustic.mobile.push.sdk.plugin.PluginRegistry
import co.acoustic.mobile.push.sdk.plugin.inbox.InboxMessageProcessor
import co.acoustic.mobile.push.sdk.plugin.inbox.InboxMessageAction
import co.acoustic.mobile.push.sdk.plugin.inapp.InAppMessageProcessor
import co.acoustic.mobile.push.sdk.registration.PhoneHomeManager
import co.acoustic.mobile.push.sdk.registration.RegistrationClientImpl
import co.acoustic.mobile.push.sdk.util.AssetsUtil
import co.acoustic.mobile.push.sdk.util.Logger
import co.acoustic.mobile.push.sdk.wi.MceSdkWakeLock
import com.google.android.gms.security.ProviderInstaller
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.lang.Exception
import kotlin.math.max

import android.content.pm.PackageManager
import android.Manifest

/**
 * Created by minho choi on 11/9/21.
 */
class SDKHandler {

    companion object {

        @JvmStatic
        private val TAG = "SDKHandler@@"

        @JvmStatic
        lateinit var context: Context

        @JvmStatic
        lateinit var result: MethodChannel.Result

        @JvmStatic
        lateinit var methodCall: MethodCall

        @JvmStatic
        private var binaryMessenger: BinaryMessenger? = null

        @JvmStatic
        private lateinit var channel : MethodChannel

        @JvmStatic
        private lateinit var mceSdkConfiguration: MceSdkConfiguration

        @JvmStatic
        private var restart = false

        @JvmStatic
        fun setup(context: Context) {
            this.context = context
            startSDK()
        }

        private fun startSDK() {
            Log.e(TAG, "startSDK")

            try {
                val configString = AssetsUtil.getAssetAsString(context, "MceConfig.json")
                parseJsonConfiguration(configString)
                if (mceSdkConfiguration == null) {
                    return
                }
                val sdkState = MceSdk.getRegistrationClient().getSdkState(
                    context
                )
                if (!mceSdkConfiguration.isAutoInitialize) {
                    if (SdkState.STOPPED != sdkState) {
                        return
                    } else {
                        Log.e(TAG, "SDK was initiated before. Tentative init is executed")
                    }
                }
                if (SdkState.STOPPED == sdkState) {
                    RegistrationClientImpl.setSdkState(context, SdkState.UNREGISTERED)
                }
                initSdk()
            } catch (ex: Exception) {
                Log.e(TAG, "Couldn't initialize MCE SDK", ex)
            }
        }

        private fun initSdk() {
            val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
            Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
                try {
                    Log.e(TAG, "Unexpected error", throwable)
                    Logger.flush()
                } catch (t: Throwable) {
                    Log.e(TAG, "Failed to log unexpected error ", t)
                }
                defaultHandler.uncaughtException(thread, throwable)
            }
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
                try {
                    ProviderInstaller.installIfNeeded(context)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to install push provider", e)
                }
            }
            reinit()
        }

        private fun setupSdkLogging() {
            if (mceSdkConfiguration.isLogFile) {
                Logger.e(
                    TAG, "External storage: " + Environment
                        .getExternalStorageState() + ", " + Environment
                        .getExternalStorageDirectory() + " " + if (Environment
                            .getExternalStorageDirectory() != null
                    ) Environment
                        .getExternalStorageDirectory().exists() else ""
                )
            } else {
                Logger.e(TAG, "No log to file")
            }
            try {
                if (Logger.initLogPersistence(
                        context,
                        mceSdkConfiguration
                    )) {
                    Logger.writeToProfile("appKey", mceSdkConfiguration.appKey)
                    // Logger.writeToProfile("senderId", mceSdkConfiguration.senderId)
                    Logger.writeToProfile(
                        "sessionEnabled",
                        java.lang.String.valueOf(mceSdkConfiguration.isSessionsEnabled)
                    )
                    Logger.writeToProfile(
                        "sessionDurationInMinutes",
                        java.lang.String.valueOf(mceSdkConfiguration.sessionTimeout)
                    )
                    Logger.writeToProfile(
                        "metricsTimeInterval",
                        java.lang.String.valueOf(mceSdkConfiguration.metricTimeInterval)
                    )
                    Logger.writeToProfile("logLevel", java.lang.String.valueOf(
                        mceSdkConfiguration.logLevel))
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to initiate logging: $e")
            }
        }

        private fun reinit() {
            RegistrationClientImpl.markSdkAsInitiated(context)
            val sdkStopped = RegistrationClientImpl.isSdkStopped(context)
            setupSdkLogging()
            SdkPreferences.setDatabaseImpl(context, mceSdkConfiguration.databaseConfiguration.databaseImplClassName)
            EncryptionPreferences.setEncryptionImpl(context, mceSdkConfiguration.databaseConfiguration.encryptionProviderClassName)
            EncryptionPreferences.setKeyGeneratorImpl(context, mceSdkConfiguration.databaseConfiguration.keyGeneratorClassName)
            EncryptionPreferences.setDatabaseEncrypted(context, mceSdkConfiguration.databaseConfiguration.isEncrypted)

            val keyRotationInterval =
                max(1, mceSdkConfiguration.databaseConfiguration.keyRotationIntervalInDays)
                    .toLong() * 24L * 60L * 60L * 1000L
            EncryptionPreferences.setKeyRotationInterval(context, keyRotationInterval)
            if (!DbAdapter.isDbAvailable(context)) {
                Logger.e(TAG, "Database not available. Aborting init")
                return
            }
            verifySdkState()
            if (restart || !sdkStopped || mceSdkConfiguration.isAutoReinitialize) {
                startMceSdk()
            } else {
                Log.e(TAG, "GDPR State detected. SDK start disabled")
            }
            SdkPreferences.setMceConfiguration(
                context,
                mceSdkConfiguration
            )
            if (LocationPreferences.isEnableLocations(context)) {
                LocationBroadcastReceiver.startLocationUpdates(context)
            }
        
        }

        private fun initMessageProcessors() {
            val pushMsg = MessageProcessorRegistry.getMessageProcessor("certifiedPushMessages")
            if (pushMsg == null) {
                MessageProcessorRegistry.registerMessageProcessor(
                    "certifiedPushMessages",
                    CertificationMessageProcessor()
                )
            }
            val inApp = MessageProcessorRegistry.getMessageProcessor("inAppMessages")
            if (inApp == null) {
                MessageProcessorRegistry.registerMessageProcessor("inAppMessages", InAppMessageProcessor())
            }
            val inbox = MessageProcessorRegistry.getMessageProcessor("messages")
            if (inbox == null) {
                MessageProcessorRegistry.registerMessageProcessor("messages", InboxMessageProcessor())
            }
        }


        private fun initNotificationActions() {
            val openInbox = MceNotificationActionRegistry.getNotificationAction(context, "openInboxMessage")
        }

        private fun startMceSdk() {
            applyMceSdkConfiguration()
            Log.e(TAG, "SDK configuration was applied")
            initMessageProcessors()
            initNotificationActions()
            try {
                //val inAppPluginClass = Class.forName("co.acoustic.mobile.push.sdk.plugin.inapp.InAppPlugin")
                //val inAppPlugin: Plugin = inAppPluginClass.newInstance() as Plugin
                //PluginRegistry.registerPlugin("inApp", inAppPlugin)
                //Log.e(TAG, "Registered inApp plugin")
            } catch (e: ClassNotFoundException) {
                Logger.e(TAG, "No inApp plugin found")
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected issue occurred while setting up InApp support")
            }
            MceSdk.getRegistrationClient().start(
                context,
                mceSdkConfiguration
            )
            Log.d(TAG, "SDK started${mceSdkConfiguration}")

            PhoneHomeManager.onAppStartup(context)
            if (MceSdk.getRegistrationClient().getRegistrationDetails(context).userId != null) {
                Log.e(
                    TAG, "userId = ${MceSdk.getRegistrationClient().getRegistrationDetails(
                        context
                    ).userId}")
                Log.e(
                    TAG, "channelId = ${MceSdk.getRegistrationClient().getRegistrationDetails(
                        context
                    ).channelId}")
                Log.e(
                    TAG, "AppKey = ${MceSdk.getRegistrationClient().getAppKey(
                        context
                    )}")
                val json = JSONObject()
                json.put("userId", MceSdk.getRegistrationClient().getRegistrationDetails(
                    context
                ).userId)
                json.put("channelId", MceSdk.getRegistrationClient().getRegistrationDetails(
                    context
                ).channelId)
                json.put("appKey", MceSdk.getRegistrationClient().getAppKey(
                    context
                ))
                FlutterAcousticSdkPushPlugin.sendEvent(json.toString())
            }
        }

        private fun verifySdkState() {
            val sdkState = MceSdk.getRegistrationClient().getSdkState(context)
            if (sdkState == null) {
                when {
                    RegistrationClientImpl.isSdkUpdating(context) -> {
                        RegistrationClientImpl.setSdkState(context, SdkState.UPDATING)
                    }
                    RegistrationClientImpl.isSdkStopped(context) -> {
                        RegistrationClientImpl.setSdkState(context, SdkState.STOPPED)
                    }
                    MceSdk.getRegistrationClient()
                        .getRegistrationDetails(context).channelId != null -> {
                        RegistrationClientImpl.setSdkState(context, SdkState.REGISTERED)
                    }
                    else -> {
                        RegistrationClientImpl.setSdkState(context, SdkState.UNREGISTERED)
                    }
                }
            }
        }

        private fun applyMceSdkConfiguration() {
            MceSdk.getNotificationsClient().notificationsPreference.setGroupByAttribution(
                context, mceSdkConfiguration.isGroupNotificationsByAttribution)
            MediaManager.initCache(
                context,
                mceSdkConfiguration
            )
            Preferences.setLong(
                context,
                MceSdkWakeLock.MCE_SDK_MAX_WAKELOCK_COUNT_PER_HOUR,
                mceSdkConfiguration.maxWakeLocksPerHour
            )
            val syncConfiguration: MceSdkConfiguration.LocationConfiguration.SyncConfiguration = mceSdkConfiguration.locationConfiguration.syncConfiguration
            LocationPreferences.setLocationsSearchRadius(context, syncConfiguration.locationSearchRadius)
            LocationPreferences.setMinLocationsPerSearch(context, syncConfiguration.minLocationsForSearch)
            LocationPreferences.setMaxLocationsPerSearch(context, syncConfiguration.maxLocationsForSearch)
            LocationPreferences.setRefAreaRadius(context, syncConfiguration.syncRadius)
            LocationPreferences.setSyncInterval(context, syncConfiguration.syncIntervalInMillis)
            LocationPreferences.setLocationResponsiveness(context, syncConfiguration.locationResponsivenessInMillis)
            val iBeaconConfiguration: MceSdkConfiguration.LocationConfiguration.IBeaconConfiguration =
                mceSdkConfiguration.locationConfiguration.getiBeaconConfiguration()
            IBeaconsPreferences.setBluetoothForegroundScanDuration(context, (iBeaconConfiguration.beaconForegroundScanDuration * 1000).toLong())
            IBeaconsPreferences.setBluetoothForegroundScanInterval(context, (iBeaconConfiguration.beaconForegroundScanInterval * 1000).toLong())
            IBeaconsPreferences.setBluetoothBackgroundScanDuration(context, (iBeaconConfiguration.beaconBackgroundScanDuration * 1000).toLong())
            IBeaconsPreferences.setBluetoothBackgroundScanInterval(context, (iBeaconConfiguration.beaconBackgroundScanInterval * 1000).toLong())
            if (iBeaconConfiguration.uuid != null) {
                IBeaconsPreferences.setBeaconsUUID(context, iBeaconConfiguration.uuid)
            } else {
                Logger.w(TAG, "Beacon UUID is null")
            }
            if (LocationPreferences.isEnableLocations(context)) {
                val locationsState = LocationPreferences.getCurrentLocationsState(
                    context
                )
                Logger.e(
                    TAG,
                    "@Location tracked beacons on start are: " + locationsState.trackedBeaconsIds,
                    SdkTags.TAG_SDK_LIFECYCLE,
                    SdkTags.TAG_SDK_LIFECYCLE_INIT,
                    SdkTags.TAG_LOCATION,
                    SdkTags.TAG_BEACON
                )
                if (locationsState.trackedBeaconsIds.isNotEmpty()) {
                    Logger.v(
                        TAG,
                        "iBeacons found. Initializing bluetooth scanner",
                        SdkTags.TAG_SDK_LIFECYCLE,
                        SdkTags.TAG_SDK_LIFECYCLE_INIT,
                        SdkTags.TAG_LOCATION,
                        SdkTags.TAG_BEACON
                    )
                    MceBluetoothScanner.startBluetoothScanner(context)
                } else {
                    Logger.v(
                        TAG,
                        "iBeacons not found.",
                        SdkTags.TAG_SDK_LIFECYCLE,
                        SdkTags.TAG_SDK_LIFECYCLE_INIT,
                        SdkTags.TAG_LOCATION,
                        SdkTags.TAG_BEACON
                    )
                }
                LocationManager.enableLocationSupport(context)
            }

            if (mceSdkConfiguration.baseUrl != null && mceSdkConfiguration.baseUrl.isNotEmpty()) {
                Endpoint.getInstance().setCustomEndpoint(mceSdkConfiguration.baseUrl)
            }
            if (mceSdkConfiguration.metricTimeInterval > 0) { SdkPreferences.setEventsInterval(
                context,
                mceSdkConfiguration.metricTimeIntervalInMillis)
            }
            RegistrationClientImpl.setInvalidateExistingUser(
                context,
                mceSdkConfiguration.isInvalidateExistingUser
            )
            RegistrationClientImpl.setAutoReinitialize(
                context,
                mceSdkConfiguration.isAutoReinitialize
            )
            val registrationDetails = MceSdk.getRegistrationClient().getRegistrationDetails(
                context
            )
            MessagingManager.setMessagingServiceImpl(context, mceSdkConfiguration.messagingService)
        }

        fun parseJsonConfiguration(configurationJSON: String?) {
            val mceJSONConfiguration = JSONObject(configurationJSON)
            val appKey = mceJSONConfiguration.getJSONObject("appKey").getString("prod")
            // val senderId = mceJSONConfiguration.getString("senderId")
            mceSdkConfiguration = MceSdkConfiguration(appKey)
            mceSdkConfiguration.isInvalidateExistingUser =
                mceJSONConfiguration.optBoolean(
                    "invalidateExistingUser",
                    mceSdkConfiguration.isInvalidateExistingUser
                )
            mceSdkConfiguration.isAutoReinitialize =
                mceJSONConfiguration.optBoolean("autoReinitialize", mceSdkConfiguration.isAutoReinitialize)
            mceSdkConfiguration.baseUrl = mceJSONConfiguration.optString("baseUrl")
            mceSdkConfiguration.messagingService = MceSdkConfiguration.MessagingService.valueOf(
                mceJSONConfiguration.optString(
                    "messagingService",
                    mceSdkConfiguration.messagingService.name
                )
            )
            mceSdkConfiguration.isSessionsEnabled =
                mceJSONConfiguration.optBoolean("sessionsEnabled", mceSdkConfiguration.isSessionsEnabled)
            mceSdkConfiguration.sessionTimeout =
                mceJSONConfiguration.optInt("sessionTimeout", mceSdkConfiguration.sessionTimeout)
            mceSdkConfiguration.metricTimeInterval =
                mceJSONConfiguration.optInt("metricTimeInterval", mceSdkConfiguration.metricTimeInterval)
            mceSdkConfiguration.logLevel = Logger.LogLevel.valueOf(
                mceJSONConfiguration.optString(
                    "loglevel",
                    mceSdkConfiguration.logLevel.name
                )
            )
            mceSdkConfiguration.isLogFile =
                mceJSONConfiguration.optBoolean("logfile", mceSdkConfiguration.isLogFile)
            mceSdkConfiguration.logIterations =
                mceJSONConfiguration.optInt("logIterations", mceSdkConfiguration.logIterations)
            mceSdkConfiguration.logIterationDurationInHours =
                mceJSONConfiguration.optInt(
                    "logIterationDurationInHours",
                    mceSdkConfiguration.logIterationDurationInHours
                )
            mceSdkConfiguration.logBufferSize =
                mceJSONConfiguration.optInt("logBufferSize", mceSdkConfiguration.logBufferSize)
            mceSdkConfiguration.isUseInMemoryImageCache =
                mceJSONConfiguration.optBoolean(
                    "useInMemoryImageCache",
                    mceSdkConfiguration.isUseInMemoryImageCache
                )
            mceSdkConfiguration.isUseFileImageCache =
                mceJSONConfiguration.optBoolean(
                    "useFileImageCache",
                    mceSdkConfiguration.isUseFileImageCache
                )
            mceSdkConfiguration.inMemoryImageCacheCapacityInMB =
                mceJSONConfiguration.optInt(
                    "inMemoryImageCacheCapacityInMB",
                    mceSdkConfiguration.inMemoryImageCacheCapacityInMB
                )
            mceSdkConfiguration.fileImageCacheCapacityInMB =
                mceJSONConfiguration.optInt(
                    "fileImageCacheCapacityInMB",
                    mceSdkConfiguration.fileImageCacheCapacityInMB
                )
            mceSdkConfiguration.isGroupNotificationsByAttribution =
                mceJSONConfiguration.optBoolean(
                    "groupNotificationsByAttribution",
                    mceSdkConfiguration.isGroupNotificationsByAttribution
                )
            mceSdkConfiguration.maxWakeLocksPerHour =
                mceJSONConfiguration.optLong("maxWakeLocksPerHour", mceSdkConfiguration.maxWakeLocksPerHour)
            mceSdkConfiguration.isAutoInitialize =
                mceJSONConfiguration.optBoolean("autoInitialize", mceSdkConfiguration.isAutoInitialize)
            val databaseConfigurationJSON = mceJSONConfiguration.optJSONObject("database")
            parseJsonDatabaseConfiguration(databaseConfigurationJSON)
            val locationConfigJSON = mceJSONConfiguration.optJSONObject("location")
            parseJsonLocationConfiguration(locationConfigJSON)
            this.mceSdkConfiguration = mceSdkConfiguration
        }


        private fun parseJsonDatabaseConfiguration(databaseConfigurationJSON: JSONObject?) {
            if (databaseConfigurationJSON != null) {
                val databaseConfiguration = mceSdkConfiguration.databaseConfiguration
                val databaseImpl =
                    databaseConfigurationJSON.optString("impl", databaseConfiguration.databaseImplClassName)
                databaseConfiguration.databaseImplClassName = databaseImpl
                val encryptionProviderImpl = databaseConfigurationJSON.optString(
                    "encryptionProvider",
                    databaseConfiguration.encryptionProviderClassName
                )
                databaseConfiguration.encryptionProviderClassName = encryptionProviderImpl
                val keyGeneratorIMpl = databaseConfigurationJSON.optString(
                    "keyGenerator",
                    databaseConfiguration.keyGeneratorClassName
                )
                databaseConfiguration.keyGeneratorClassName = keyGeneratorIMpl
                val keyRotationIntervalInDays = databaseConfigurationJSON.optInt(
                    "keyRotationIntervalInDays",
                    databaseConfiguration.keyRotationIntervalInDays
                )
                databaseConfiguration.keyRotationIntervalInDays = keyRotationIntervalInDays
                val encrypted =
                    databaseConfigurationJSON.optBoolean("encrypted", databaseConfiguration.isEncrypted)
                databaseConfiguration.isEncrypted = encrypted
            }
        }

        private fun parseJsonLocationConfiguration(locationConfigJSON: JSONObject?) {
            if (locationConfigJSON != null) {
                val autoInitializeLocation = locationConfigJSON.optBoolean("autoInitialize", true)
                if (autoInitializeLocation && (context.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)) {
                    Log.v(TAG, "Location Auto Initialize")
                    val prefs: SharedPreferences =
                        context.getSharedPreferences("MCE", Context.MODE_PRIVATE)
                    val prefEditor = prefs.edit()
                    prefEditor.putBoolean("locationInitialized", true)
                    prefEditor.commit()
                    LocationManager.enableLocationSupport(context)
                } else {
                    Log.v(TAG, "!Location Auto Initialize")
                }
                val syncConfigJSON = locationConfigJSON.optJSONObject("sync")
                if (syncConfigJSON != null) {
                    val syncConfiguration = mceSdkConfiguration.locationConfiguration.syncConfiguration
                    syncConfiguration.locationSearchRadius =
                        syncConfigJSON.optInt("locationSearchRadius", syncConfiguration.locationSearchRadius)
                    syncConfiguration.syncRadius =
                        syncConfigJSON.optInt("syncRadius", syncConfiguration.syncRadius)
                    syncConfiguration.syncInterval =
                        syncConfigJSON.optInt("syncInterval", syncConfiguration.syncInterval)
                    syncConfiguration.locationResponsiveness =
                        syncConfigJSON.optInt(
                            "locationResponsiveness",
                            syncConfiguration.locationResponsiveness
                        )
                    syncConfiguration.minLocationsForSearch =
                        syncConfigJSON.optInt(
                            "minLocationsForSearch",
                            LocationPreferences.DEFAULT_MIN_LOCATIONS_PER_SEARCH
                        )
                    syncConfiguration.maxLocationsForSearch =
                        syncConfigJSON.optInt("maxLocationsForSearch", syncConfiguration.maxLocationsForSearch)
                }
                val beaconConfigJSON = locationConfigJSON.optJSONObject("ibeacon")
                if (beaconConfigJSON != null) {
                    val iBeaconConfiguration =
                        mceSdkConfiguration.locationConfiguration.getiBeaconConfiguration()
                    iBeaconConfiguration.uuid = beaconConfigJSON.optString("uuid", iBeaconConfiguration.uuid)
                    iBeaconConfiguration.beaconForegroundScanDuration =
                        beaconConfigJSON.optInt(
                            "beaconForegroundScanDuration",
                            iBeaconConfiguration.beaconForegroundScanDuration
                        )
                    iBeaconConfiguration.beaconForegroundScanInterval =
                        beaconConfigJSON.optInt(
                            "beaconForegroundScanInterval",
                            iBeaconConfiguration.beaconForegroundScanInterval
                        )
                    iBeaconConfiguration.beaconBackgroundScanDuration =
                        beaconConfigJSON.optInt(
                            "beaconBackgroundScanDuration",
                            iBeaconConfiguration.beaconBackgroundScanDuration
                        )
                    iBeaconConfiguration.beaconBackgroundScanInterval =
                        beaconConfigJSON.optInt(
                            "beaconBackgroundScanInterval",
                            iBeaconConfiguration.beaconBackgroundScanInterval
                        )
                }
            }
        }
    }
}