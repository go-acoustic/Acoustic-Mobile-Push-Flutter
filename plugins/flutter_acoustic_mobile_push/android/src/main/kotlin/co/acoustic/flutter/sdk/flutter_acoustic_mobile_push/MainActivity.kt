package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push

import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import co.acoustic.mobile.push.sdk.api.notification.DelayedNotificationAction
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import com.google.firebase.FirebaseApp
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Activity

/**
 * Created by minho choi on 11/9/21.
 */
class MainActivity: FlutterActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FirebaseApp.initializeApp(this)

        Log.d("TAG, MAIN" , "PLUGIN MAIN ACTIVITY: onCreate")

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onResume() {
        super.onResume()
    }

    override fun onPause() {
        super.onPause()
    }


    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            0 -> {
                if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                    FlutterAcousticSdkPushPlugin.sendEvent("locationPermission", "true")
                } else {

                }
            }
        }
    }
}