#import "FlutterAcousticMobilePushBeaconPlugin.h"
#import <CoreLocation/CoreLocation.h>
#import <AcousticMobilePush/AcousticMobilePush.h>

@implementation FlutterAcousticMobilePushBeaconPlugin

static FlutterMethodChannel * channel;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_acoustic_mobile_push_beacon"
            binaryMessenger:[registrar messenger]];
  FlutterAcousticMobilePushBeaconPlugin* instance = [[FlutterAcousticMobilePushBeaconPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([@"getIBeaconLocations" isEqualToString:call.method]) {
      if (MCESdk.sharedInstance.config.appKey.length == 0) {
            return NSLog(@"No App Key");
          }
      NSString* uuid = [NSString stringWithFormat: @"%@", [[MCEConfig sharedInstance] beaconUUID]];
      [channel invokeMethod: @"UUID" arguments: uuid result: nil];
      
    NSMutableArray * beaconRegions = [NSMutableArray array];
    NSSet * regions = [[MCELocationDatabase sharedInstance] beaconRegions];
    for (CLBeaconRegion * region in regions) {
        NSNumber* major = [NSNumber numberWithInt: 0];
        NSNumber* minor = [NSNumber numberWithInt: 0];
        NSString* regionID = @"";
        
        if (region.major != nil) {
            major = region.major;
        }
        if (region.minor != nil) {
            minor = region.minor;
        }
        if (region.identifier != nil) {
            regionID = region.identifier;
        }

        [beaconRegions addObject: @{@"major": major, @"minor": minor, @"id": regionID}];
    }
    
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject: beaconRegions options:NSJSONWritingPrettyPrinted error: nil];
      NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      result(jsonString);

  } else {
      
    result(FlutterMethodNotImplemented);
  }
}

@end

