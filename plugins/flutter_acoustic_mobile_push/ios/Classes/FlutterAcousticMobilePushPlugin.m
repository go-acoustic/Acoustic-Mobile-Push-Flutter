#import "FlutterAcousticMobilePushPlugin.h"
// #if __has_include(<flutter_acoustic_mobile_push/flutter_acoustic_mobile_push-Swift.h>)
// #import <flutter_acoustic_mobile_push/flutter_acoustic_mobile_push-Swift.h>
// #else
// // Support project import fallback if the generated compatibility header
// // is not copied when this plugin is created as a library.
// // https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
// #import "flutter_acoustic_mobile_push-Swift.h"
// #endif
#import <AcousticMobilePush/AcousticMobilePush.h>

static NSMutableSet* registeredAction = NULL;

@implementation FlutterAcousticMobilePushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_acoustic_mobile_push"
            binaryMessenger:[registrar messenger]];
  FlutterAcousticMobilePushPlugin* instance = [[FlutterAcousticMobilePushPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (registeredAction == nil) {
          registeredAction = [NSMutableSet set];
  }
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"register" isEqualToString: call.method]) {
      NSString* appKey = MCERegistrationDetails.sharedInstance.appKey;
      NSString* channelId = MCERegistrationDetails.sharedInstance.channelId;
      NSString* userId = MCERegistrationDetails.sharedInstance.userId;
      
      NSDictionary * payload = @{
          @"userId": userId,
          @"channelId": channelId,
          @"appKey": appKey,
      };
      result(payload);

  } else if ([@"registerCustomAction" isEqualToString:call.method]) {

    NSLog(@"register CUSTOM ACTION LOG");

      BOOL isContained = [registeredAction containsObject: call.arguments];
      if (isContained) {
          [MCEActionRegistry.sharedInstance unregisterAction: call.arguments];
          result(@"Custom action type $name is already registered");
      } else {
          [registeredAction addObject: call.arguments];
          SEL aSelector = @selector(registerAction);
          result(@"Registering Custom Action: $name");

          [MCEActionRegistry.sharedInstance registerTarget: nil
                                              withSelector: aSelector
                                                 forAction: call.arguments];
      }
  } else if ([@"unregisterCustomAction" isEqualToString:call.method]) {
      BOOL isContained = [registeredAction containsObject: call.arguments];
      if (isContained) {
          [registeredAction removeObject: call.arguments];
          [MCEActionRegistry.sharedInstance unregisterAction: call.arguments];
          result(@"Unregistering Custom Action: $name");
      } else {
        result(@"Custom action: $name is not registered");
      }
  } else if ([@"updateUserAttributes" isEqualToString:call.method]) {
    
    NSLog(@"updateUserAtt should be called with a template as the first argument");

    //  NSMutableDictionary* dic = (NSMutableDictionary*)call.arguments;

    //       NSString* type = @"";

    //       if (dic[@"type"] != nil) {
    //           type = dic[@"type"];
    //       }

    //   NSString* type = call.arguments[@"type"];
      switch (type) {
                case @"date":
                {
                    NSDate * dateValue = call.arguments[@"value"];

                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateStyle = NSDateFormatterShortStyle;
                    dateFormatter.timeStyle = NSDateFormatterShortStyle;

                    if(dateValue && [dateValue respondsToSelector:@selector(isEqualToString:)]) {
                        NSDate * dValue = [dateFormatter dateFromString:dateValue];
                        if(dValue) {
                            dateValue = dValue;
                        }
                    }
                    [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: dateValue}];
                    break;
                }
                case @"string":
                {
                    NSString * stringValue = call.arguments[@"value"];
                    if(value && [value respondsToSelector:@selector(isEqualToString:)]) {
                        stringValue = value;
                    }
                    
                    [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, stringValue], @"color": UIColor.warningColor}];
                    [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: stringValue}];
                    break;
                }
                case @"boolean":
                {
                    BOOL boolValue = call.arguments[@"value"];

                    [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%@", name, @(self.boolSwitch.on)], @"color": UIColor.warningColor}];
                    [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: @(self.boolSwitch.on) }];
                    break;
                }
                case @"number":
                {
                    double doubleValue = call.arguments[@"value"];
                    if(value && [value respondsToSelector:@selector(isEqualToString:)]) {
                        doubleValue = [value doubleValue];
                    }

                    [self updateStatus: @{@"text": [NSString stringWithFormat: @"Queued User Attribute Update\n%@=%f", name, doubleValue], @"color": UIColor.warningColor}];
                    [MCEAttributesQueueManager.sharedInstance updateUserAttributes: @{name: @(doubleValue)}];
                    break;
                }
            }
    

  } else if ([@"deleteUserAttributes" isEqualToString:call.method]) {
      NSMutableArray* array = [NSMutableArray array];
      [array addObject: call.method];
      
      NSMutableArray* keyList = [NSMutableArray array];
//      for (id object in array) {
//          // do something with object
//      }
      
      
  } else if ([@"sendEvents" isEqualToString:call.method]) {

      NSLog(@"registerInApp should be called with a template as the first argument");
    
      NSMutableDictionary* dic = (NSMutableDictionary*)call.arguments;

      NSString* type = @"";
      NSString* name = @"";
      NSString* timestamp = @"";
      NSDate* date = [NSDate date];
      NSDictionary* attributes = [NSDictionary dictionary];
      NSString* attribution = @"";
      NSString* mailingId = @"";
      BOOL immediate = NO;
 
      if (dic[@"type"] != nil) {
          type = dic[@"type"];
      }
      
      if (dic[@"name"] != nil) {
          name = dic[@"name"];
      }
      
      if (dic[@"timestamp"] != nil) {
          timestamp = dic[@"timestamp"];
      }
      
      if (dic[@"attribution"] != nil) {
          attribution = dic[@"attribution"];
      }
      
      if (dic[@"mailingId"] != nil) {
          mailingId = dic[@"mailingId"];
      }
      
      if (dic[@"immediate"] != nil) {
          NSNumber* number = dic[@"immediate"];
          if (number != nil && [number intValue] == 1) {
              immediate = YES;
          }
      }
      
      if (timestamp.length > 0) {
          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
          [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"];
          date = [dateFormatter dateFromString: timestamp];
      }
      
      MCEEvent* event = [[MCEEvent alloc] initWithName: name
                                                  type: type
                                             timestamp: date
                                            attributes: attributes
                                           attribution: attribution
                                             mailingId: mailingId];
      
      [MCEEventService.sharedInstance addEvent: event immediate: immediate];
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)registerAction {
    
}


@end
