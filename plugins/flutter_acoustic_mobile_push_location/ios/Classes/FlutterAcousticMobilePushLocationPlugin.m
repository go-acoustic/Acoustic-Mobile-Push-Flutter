#import "FlutterAcousticMobilePushLocationPlugin.h"
#import <CoreLocation/CoreLocation.h>
#import <AcousticMobilePush/AcousticMobilePush.h>


@implementation FlutterAcousticMobilePushLocationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flutter_acoustic_mobile_push_location" binaryMessenger:[registrar messenger]];
  FlutterAcousticMobilePushLocationPlugin* instance = [[FlutterAcousticMobilePushLocationPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"checkLocationPermission" isEqualToString:call.method]) {
    MCEConfig * config = MCESdk.sharedInstance.config;
    if(config.geofenceEnabled) {
        switch(CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusDenied:
                result(@"denied");
                break;
            case kCLAuthorizationStatusNotDetermined:
                result(@"delayed");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                result(@"always");
                break;
            case kCLAuthorizationStatusRestricted:
                result(@"restricted");
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                result(@"enabled");
                break;
        }
    } else {
      result(@"disabled");
    }
  } else if ([@"enableLocation" isEqualToString:call.method]) {
    [MCESdk.sharedInstance manualLocationInitialization];
  } else if ([@"syncLocations" isEqualToString:call.method]) {
    [[[MCELocationClient alloc] init] scheduleSync];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
