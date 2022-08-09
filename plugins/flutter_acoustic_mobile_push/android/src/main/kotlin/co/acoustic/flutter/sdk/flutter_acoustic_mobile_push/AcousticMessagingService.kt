package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push

import android.content.Context
import android.util.Log
import co.acoustic.mobile.push.sdk.api.MceSdkConfiguration
import co.acoustic.mobile.push.sdk.api.MessagingService

/**
 * Created by minho choi on 11/8/21.
 */
class AcousticMessagingService(): MessagingService {



    override fun initialize(p0: Context?, p1: MceSdkConfiguration?) {
        Log.e("MessagingService~~~", "initialize")
    }

    override fun register(p0: Context?): Boolean {
        Log.e("MessagingService~~~", "register : ${p0.toString()}")

        return true
    }

    override fun getServiceName(): String {
        Log.e("MessagingService~~~", "getServiceName")
        return "getServiceName"

    }

}