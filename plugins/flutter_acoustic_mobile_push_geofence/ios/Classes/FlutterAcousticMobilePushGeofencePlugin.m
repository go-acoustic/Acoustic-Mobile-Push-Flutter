#import "FlutterAcousticMobilePushGeofencePlugin.h"
#import <CoreLocation/CoreLocation.h>
#import <AcousticMobilePush/AcousticMobilePush.h>

@implementation FlutterAcousticMobilePushGeofencePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_acoustic_mobile_push_geofence"
            binaryMessenger:[registrar messenger]];
  FlutterAcousticMobilePushGeofencePlugin* instance = [[FlutterAcousticMobilePushGeofencePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (MCESdk.sharedInstance.config.appKey.length == 0) {
  return NSLog(@"No App Key");
}

    NSLog(@"FlutterAcousticMobilePushGeofencePlugin This is a test message %@ %@", call.method, call.arguments);
   if ([@"geofencesNearCoordinate" isEqualToString:call.method]) {

    NSMutableArray * geofence_return = [NSMutableArray array];
      
    double latitude = [call.arguments[@"latitude"] doubleValue];
    double longitude = [call.arguments[@"longitude"] doubleValue];
    int radius = [call.arguments[@"radius"] intValue];

    NSMutableSet * monitoredRegionIds = [NSMutableSet set];
    CLLocationManager * locationManager = [[CLLocationManager alloc] init];
    for (CLRegion * region in locationManager.monitoredRegions) {
        [monitoredRegionIds addObject:region.identifier];
    }
       if (latitude == 0) latitude = 37.33233141;
       if (longitude == 0) longitude = -122.0312186;

    NSSet * geofences = [MCELocationDatabase.sharedInstance geofencesNearCoordinate:CLLocationCoordinate2DMake(latitude, longitude) radius: 100000];
    for (MCEGeofence * geofence in geofences) {
        BOOL active = [monitoredRegionIds containsObject: geofence.locationId];
        [geofence_return addObject: @{@"latitude": @(geofence.latitude), @"longitude": @(geofence.longitude), @"radius": @(geofence.radius), @"id": geofence.locationId, @"active": @(active) } ];
    }
      
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject: geofence_return options:NSJSONWritingPrettyPrinted error: nil];
      NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      result(jsonString);

  }
   else if ([@"sendLocationPermission" isEqualToString: call.method]) {
       result(@"Enabled");
   }
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
