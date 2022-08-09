#import "FlutterAcousticMobilePushSnoozePlugin.h"
#import <AcousticMobilePush/AcousticMobilePush.h>

@implementation FlutterAcousticMobilePushSnoozePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_acoustic_mobile_push_snooze"
            binaryMessenger:[registrar messenger]];
  FlutterAcousticMobilePushSnoozePlugin* instance = [[FlutterAcousticMobilePushSnoozePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

                  NSLog(@"FlutterAcousticMobilePushSnoozePlugin This is a test message %@", call.method);

  if ([@"snoozeAction" isEqualToString:call.method]) {
    NSDictionary* action = call.arguments[@"action"];
    NSDictionary* payload = call.arguments[@"payload"];
    [self snooze: action payload: payload];
  }
  
  else {
    result(FlutterMethodNotImplemented);
  }
}

-(void) snooze:(NSDictionary *)action payload: (NSDictionary*)payload {
    NSInteger minutes = [[action valueForKey:@"value"] integerValue];
    NSString* mailingId = [action valueForKey:@"mailingId"];
    NSLog(@"Snooze for %ld minutes", (long)minutes);
    UILocalNotification * notification = [[UILocalNotification alloc] init];
    
    notification.userInfo = payload;
    if(payload[@"aps"][@"category"]) {
        notification.category = payload[@"aps"][@"category"];
    }
    
    if(payload[@"aps"][@"sound"]) {
        notification.soundName = payload[@"aps"][@"sound"];
    }
    
    if(payload[@"aps"][@"badge"]) {
        notification.applicationIconBadgeNumber = [payload[@"aps"][@"badge"] integerValue];
    }
    
    if(mailingId != nil) {
        notification.alertAction = mailingId;
        notification.hasAction = true;
    } else {
        notification.hasAction = false;
    }
    
    if (payload[@"aps"]) {
        [[MCESdk sharedInstance] presentDynamicCategoryNotification: payload[@"aps"]];
        
    }
    
//   NSString * alertBody = [[[MCESdk sharedInstance] payload[@"aps"]]];
//   notification.alertBody = alertBody;
    
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:minutes*60];
    [[UIApplication sharedApplication] scheduleLocalNotification: notification];
}

@end
