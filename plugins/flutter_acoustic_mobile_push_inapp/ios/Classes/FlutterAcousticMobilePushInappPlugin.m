#import "FlutterAcousticMobilePushInappPlugin.h"
#import <AcousticMobilePush/AcousticMobilePush.h>

@interface FlutterAcousticMobilePushInappPlugin ()
@property NSMutableDictionary * inAppTemplateModules;
@end

enum {
    BOTTOM_BANNER_ITEM = 0,
    TOP_BANNER_ITEM = 1,
    IMAGE_ITEM = 2,
    VIDEO_ITEM = 3
} InAppType;

static FlutterMethodChannel * channel;
static FlutterAcousticMobilePushInappPlugin * plugin;


@implementation FlutterAcousticMobilePushInappPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_acoustic_mobile_push_inapp"
            binaryMessenger:[registrar messenger]];
    plugin = [[FlutterAcousticMobilePushInappPlugin alloc] init];
  [registrar addMethodCallDelegate:plugin channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"cannedInAppBottomBanner" isEqualToString:call.method]) {
      [FlutterAcousticMobilePushInappPlugin createInApp: call.arguments inAppType: BOTTOM_BANNER_ITEM];
  } else if ([@"cannedInAppTopBanner" isEqualToString:call.method]) {
      [FlutterAcousticMobilePushInappPlugin createInApp: call.arguments inAppType: TOP_BANNER_ITEM];
  } else if ([@"cannedInAppImageBanner" isEqualToString:call.method]) {
      [FlutterAcousticMobilePushInappPlugin createInApp: call.arguments inAppType: IMAGE_ITEM];
  } else if ([@"cannedInAppVideoBanner" isEqualToString:call.method]) {
      [FlutterAcousticMobilePushInappPlugin createInApp: call.arguments inAppType: VIDEO_ITEM];
  } else if ([@"cannedInAppContent" isEqualToString:call.method]){
      NSDictionary *inAppMessage = call.arguments;
      NSLog(@"inAppMessage --> %@", inAppMessage);
      NSDictionary *payload = @{@"inApp": inAppMessage};
      
      [MCEInAppManager.sharedInstance processPayload: payload];
  }
  else if ([@"deleteInApp" isEqualToString:call.method]) {
    NSString *inAppMessageId = call.arguments;
    MCEInAppMessage * inAppMessage = [MCEInAppManager.sharedInstance inAppMessageById: inAppMessageId];
    if(inAppMessage) {
      [[MCEInAppManager sharedInstance] disable: inAppMessage];
    }
  } else if ([@"createInApp" isEqualToString:call.method]) {

    NSDictionary* content = call.arguments[@"content"];
    NSString* template = call.arguments[@"template"];
    NSArray* rules = call.arguments[@"rules"];
    NSInteger maxViews = [call.arguments[@"maxViews"] intValue];
    NSString* attribution = call.arguments[@"attribution"];
    NSString* mailingId = call.arguments[@"mailingId"];

    NSMutableDictionary * mce = [NSMutableDictionary dictionary];
    if(mailingId && [mailingId respondsToSelector:@selector(isEqualToString:)]) {
      mce[@"mailingId"] = mailingId;
    }
    if(attribution && [attribution respondsToSelector:@selector(isEqualToString:)]) {
      mce[@"attribution"] = attribution;
    }
    NSMutableDictionary * inApp = [NSMutableDictionary dictionary];
    if(maxViews) {
      inApp[@"maxViews"] = @(maxViews);
    }
    
    if(template && [template respondsToSelector:@selector(isEqualToString:)]) {
      inApp[@"template"] = template;
    } else {
        NSLog(@"Template is required for createInApp call.");
        return;
    }
    
    if(content && [content respondsToSelector:@selector(isEqualToDictionary:)]) {
        inApp[@"content"] = content;
    } else {
        NSLog(@"Content is required for createInApp call.");
        return;
    }
    
    if(rules && [rules respondsToSelector:@selector(isEqualToArray:)]) {
        inApp[@"rules"] = rules;
    } else {
        NSLog(@"Rules are required for createInApp call.");
        return;
    }
    
    NSDictionary * payload = @{@"mce": mce, @"inApp": inApp};
    [MCEInAppManager.sharedInstance processPayload: payload];
  } else if ([@"executeInApp" isEqualToString:call.method]) {
    NSArray* rules = call.arguments[@"rules"];
    for(NSString * rule in rules) {
      if(![rule respondsToSelector:@selector(isEqualToString:)]) {
          NSLog(@"executeInApp should be called with an array of strings.");
          return;
      }
    }

    //  NSLog(@"payloadData --> %@", payload);

    [MCEInAppManager.sharedInstance fetchInAppMessagesForRules:rules completion:^(NSMutableArray *inAppMessages, NSError *error) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: inAppMessages[0] options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"fetchInAppMessagesForRules %@", jsonString);

        result(jsonString);
    }];
    
  } else if ([@"recordViewForInAppMessage" isEqualToString:call.method]) {

      NSLog(@"recordViewForInAppMessage is active");

      NSString *inAppMessageById = call.arguments;

      NSLog(@"recordViewForInAppMessageArgs %@", inAppMessageById);
      
      MCEInAppMessage * inAppMessage = [MCEInAppManager.sharedInstance inAppMessageById: inAppMessageById];
      if (inAppMessage.attribution != nil) {
        NSLog(@"recordViewForInAppMessage internal is running");
        [[MCEEventService sharedInstance] recordViewForInAppMessage: inAppMessage attribution: inAppMessage.attribution mailingId: inAppMessage.mailingId];
          }

  } else if ([@"registerInApp" isEqualToString:call.method]) {
    NSString* template = call.arguments[@"template"];
    NSString* module = call.arguments[@"module"];
    NSNumber* height = call.arguments[@"height"];

    if(![template respondsToSelector:@selector(isEqualToString:)]) {
        NSLog(@"registerInApp should be called with a template as the first argument");
        return;
    }
    
    if(![module respondsToSelector:@selector(isEqualToString:)]) {
        NSLog(@"registerInApp should be called with a module as the second argument");
        return;
    }
    
    NSMutableDictionary * value = [@{@"module": module} mutableCopy];
    if(height && [height respondsToSelector:@selector(floatValue)]) {
        value[@"height"] = height;
    }
    
    self.inAppTemplateModules[template] = value;
  } else if ([@"getSync" isEqualToString:call.method]) {
       if (MCESdk.sharedInstance.config.appKey.length == 0) {
    return NSLog(@"No App Key");
  }
    [MCEInboxQueueManager.sharedInstance syncInbox];
  } else if ([@"clickInApp" isEqualToString:call.method]) {
    NSString *inAppMessageById = call.arguments;
    MCEInAppMessage * inAppMessage = [MCEInAppManager.sharedInstance inAppMessageById: inAppMessageById];
    
    NSDictionary * payload = @{@"mce": [NSMutableDictionary dictionary]};
    if(inAppMessage.attribution) {
        payload[@"mce"][@"attribution"] = inAppMessage.attribution;
    }
    if(inAppMessage.mailingId) {
        payload[@"mce"][@"mailingId"] = inAppMessage.mailingId;
    }
    [[MCEInAppManager sharedInstance] disable: inAppMessage];
    [[MCEActionRegistry sharedInstance] performAction: inAppMessage.content[@"action"] forPayload: payload source:InAppSource attributes: nil userText: nil];
  } else if ([@"getInAppMessageTemplate" isEqualToString:call.method]) {
      if (MCESdk.sharedInstance.config.appKey.length == 0) {
        return NSLog(@"No App Key");
      }
      
      NSArray* rules = call.arguments;
      [MCEInAppManager.sharedInstance fetchInAppMessagesForRules:rules completion:^(NSMutableArray *inAppMessages, NSError *error) {
          
          NSLog(@"inAppMessages --> %lu", (unsigned long)inAppMessages.count);
          if (inAppMessages.count > 0) {
              MCEInAppMessage* inAppMessage = [inAppMessages objectAtIndex: 0];
              NSLog(@"mes --> %@", inAppMessage);
              NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
              if (inAppMessage.inAppMessageId != nil) {
                  dic[@"inAppMessageId"] = inAppMessage.inAppMessageId;
              }
              if ([NSNumber numberWithInteger: inAppMessage.numViews] != nil) {
                  dic[@"numViews"] = [NSNumber numberWithInteger: inAppMessage.numViews];
              }

              if ([NSNumber numberWithInteger: inAppMessage.maxViews] != nil) {
                  dic[@"maxViews"] = [NSNumber numberWithInteger: inAppMessage.maxViews];
              }
              if (inAppMessage.templateName != nil) {
                  dic[@"templateName"] = inAppMessage.templateName;
              }
              if (inAppMessage.content != nil) {
                  dic[@"templateContent"] = inAppMessage.content;
              }
              if (inAppMessage.rules != nil) {
                  dic[@"rules"] = inAppMessage.rules;
              }
            

              NSData *jsonData = [NSJSONSerialization dataWithJSONObject: dic options:NSJSONWritingPrettyPrinted error: nil];
              NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
              NSLog(@"jsonString --> %@", jsonString);
              NSLog(@"jsonData --> %@", jsonData);

              [channel invokeMethod: @"InAppMessage" arguments: jsonString result: nil];
              
              [[MCEInAppManager sharedInstance] incrementView: inAppMessage];

              
          }
      }];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}
+(void)createInApp: (NSString*)dic
         inAppType: (int)type
{

        if (MCESdk.sharedInstance.config.appKey.length == 0) {
    return NSLog(@"No App Key");
  }
    NSDictionary* banner = @{};
    if (type == 0) {
        banner = [FlutterAcousticMobilePushInappPlugin createCannedInAppString: BOTTOM_BANNER_ITEM];
    } else if (type == 1) {
        banner = [FlutterAcousticMobilePushInappPlugin createCannedInAppString: TOP_BANNER_ITEM];
    } else if (type == 2) {
        banner = [FlutterAcousticMobilePushInappPlugin createCannedInAppString: IMAGE_ITEM];
    } else if (type == 3) {
        banner = [FlutterAcousticMobilePushInappPlugin createCannedInAppString: VIDEO_ITEM];
    }
    /*
     - (void) processPayload: (NSDictionary * _Nullable) payload;

     - (void) fetchInAppMessagesForRules: (NSArray * _Nonnull) names completion: (void (^_Nonnull)(NSMutableArray * _Nonnull inAppMessages, NSError * _Nullable error)) completion;
     
     */
      NSLog(@"BANNER PAYLOAD: %@ ", banner);
      NSLog(@"TEST ON EXECUTION");
    [[MCEInAppManager sharedInstance] processPayload: banner];
}

+(NSDictionary*)createCannedInAppString: (int)cannedType
{ 
    // NSDate* currentDate = [NSDate date];
    NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingUnit: NSCalendarUnitDay
                                                                value: 1
                                                               toDate: [NSDate date]
                                                              options: 0];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingUnit: NSCalendarUnitDay
                                                                 value: -1
                                                                toDate: [NSDate date]
                                                               options: 0];


    NSDictionary *userInfo;
    int intCannedType = cannedType; 
    
    switch (intCannedType)
    {
      case TOP_BANNER_ITEM:{
         userInfo = @{@"inApp": @{
                                         @"rules": @[@"topBanner", @"all"],
                                         @"maxViews": @5,
                                         @"template": @"default",
                                         @"content": @{
                                                 @"orientation":@"top",
                                                 @"title":@"This is a Top Ban title",
                                                 @"action": @{@"type":@"url", @"value": @"http://acoustic.co"},
                                                 @"text":@"Top Banner Template Text",
                                                 @"icon": @"note",
                                                 @"color": @"0077FF",
                                                 @"mainImage": @"https://thumbs.dreamstime.com/b/sunset-beach-sunrays-133301221.jpg"
                                                 },
//
                                         @"triggerDate": yesterday,
                                         @"expirationDate": tomorrow,
                                         },
                                 };
        break;
                            
      }
      case BOTTOM_BANNER_ITEM:{
           userInfo = @{@"inApp": @{
                                         @"rules": @[@"bottomBanner", @"all"],
                                         @"numViews": @0,
                                         @"maxViews": @5,
                                         @"template": @"default",
                                         @"content": @{
                                                 @"orientation":@"bottom",
                                                 @"title":@"This is a Bottom Ban title",
                                                 @"action": @{@"type":@"url", @"value": @"http://acoustic.co"},
                                                 @"text":@"Bottom Banner Template Text",
                                                 @"icon": @"note",
                                                 @"color": @"0077FF",
                                                 @"mainImage": @"https://thumbs.dreamstime.com/b/sunset-beach-sunrays-133301221.jpg"
                                                 },
                                         @"triggerDate": yesterday,
                                         @"expirationDate": tomorrow,
                                         },
                                 };
        break;
      }
      case IMAGE_ITEM:{
         userInfo = @{@"inApp": @{
                                         @"rules": @[@"image", @"all"],
                                         @"maxViews": @5,
                                         @"template": @"image",
                                         @"content": @{
                                                 @"orientation":@"bottom",
                                                 @"title":@"This is an Image title",
                                                 @"action": @{@"type":@"url", @"value": @"http://acoustic.co"},
                                                 @"text":@"Image Banner Template Text",
                                                 @"icon": @"note",
                                                 @"color": @"0077FF",
                                                 @"image": @"https://cdn3.dpmag.com/2020/09/9-14-Autumn-Sunset-A.jpg"

                                                 },
                                         @"triggerDate": yesterday,
                                         @"expirationDate": tomorrow,
                                         },
                                 };
        break;
      }
      case VIDEO_ITEM:{
        userInfo = @{@"inApp": @{
                                         @"rules": @[@"video", @"all"],
                                         @"maxViews": @5,
                                         @"template": @"video",
                                         @"content": @{
                                                 @"orientation":@"bottom",
                                                 @"title":@"This is a Video title",
                                                 @"action": @{@"type":@"url", @"value": @"http://acoustic.co"},
                                                 @"text":@"Video Banner Template Text",
                                                 @"icon": @"note",
                                                 @"color": @"0077FF",
                                                 @"video": @"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"

                                                 },
                                         @"triggerDate": yesterday,
                                         @"expirationDate": tomorrow,
                                         },
                                 };
        break;
      } 
    }

     NSLog(@"USERINFO PAYLOAD: %@ ", userInfo);
    return userInfo;

}
@end
