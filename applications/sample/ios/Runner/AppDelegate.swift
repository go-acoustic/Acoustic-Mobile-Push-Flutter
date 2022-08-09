import UIKit
import Flutter
import GoogleMaps
import UserNotifications


@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GMSServices.provideAPIKey("INSERT-API-KEY-HERE")
      GeneratedPluginRegistrant.register(with: self)
      application.registerForRemoteNotifications()
              
              // iOS 10+ Push Message Registration, some versions of iOS have different options available
              let options: UNAuthorizationOptions = {
                  if #available(iOS 12.0, *) {
                      return [.alert, .sound, .carPlay, .badge, .providesAppNotificationSettings]
                  }
                  return [.alert, .sound, .carPlay, .badge]
              }()
              
              // Request User Authentication to show notifications
              UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
                  
                  if let error = error {
                      print("Couldn't request user authentication \(error.localizedDescription)")
                      return
                  }
                  if granted {
                      print("User provided authorization to show notifications")
                  } else {
                      print("User did not provide authorization to show notifications")
                  }

                  // Setup any app specific hardcoded notification categories, Acoustic push messages will create their own notification categores as needed to support the push message sent
                  UNUserNotificationCenter.current().setNotificationCategories( self.notificationCategories() )
              })
      
      

    return true
  }
    
    func notificationCategories() -> Set<UNNotificationCategory> {
            // iOS 10+ Example static action category:
            let acceptAction = UNNotificationAction(identifier: "Accept", title: "Accept", options: [.foreground])
            let rejectAction = UNNotificationAction(identifier: "Reject", title: "Reject", options: [.destructive])
            let category = UNNotificationCategory(identifier: "example", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [.customDismissAction])
            
            return Set(arrayLiteral: category)
        }

}
