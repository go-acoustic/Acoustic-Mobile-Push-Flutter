import Flutter
import UIKit

public class SwiftFlutterAcousticMobilePushBeaconPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_acoustic_mobile_push_beacon", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterAcousticMobilePushBeaconPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
