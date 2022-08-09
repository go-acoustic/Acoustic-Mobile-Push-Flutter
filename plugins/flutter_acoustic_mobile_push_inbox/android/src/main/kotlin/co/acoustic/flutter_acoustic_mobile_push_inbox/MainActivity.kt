package co.acoustic.flutter_acoustic_mobile_push_inbox

import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import co.acoustic.mobile.push.sdk.api.notification.DelayedNotificationAction
import co.acoustic.mobile.push.sdk.api.notification.MceNotificationActionRegistry
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Activity


/**
 * Created by minho choi on 11/9/21.
 */
class MainActivity: FlutterActivity() {

    companion object {
        lateinit var activity: Activity
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MainActivity.activity = this
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
}