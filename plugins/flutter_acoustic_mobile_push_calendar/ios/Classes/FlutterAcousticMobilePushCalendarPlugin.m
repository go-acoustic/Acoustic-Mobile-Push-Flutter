#import "FlutterAcousticMobilePushCalendarPlugin.h"

@implementation FlutterAcousticMobilePushCalendarPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_acoustic_mobile_push_calendar"
            binaryMessenger:[registrar messenger]];
  FlutterAcousticMobilePushCalendarPlugin* instance = [[FlutterAcousticMobilePushCalendarPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

          NSLog(@"FlutterAcousticMobilePushCalendarPlugin This is a test message %@", call.method);

  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"calendarAction" isEqualToString: call.method]) {
    NSDictionary* action = call.arguments[@"action"];
    [self performAction:action];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(void) performAction:(NSDictionary *)action {
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performAction:action];
        });
        return;
    }
    
    NSISO8601DateFormatter * formatter = [[NSISO8601DateFormatter alloc] init];
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if(error) {
            NSLog(@"Could not add to calendar %@", [error localizedDescription]);
            return;
        }

        if(!granted) {
            NSLog(@"Could not get access to EventKit, can't add to calendar");
            return;
        }

        EKEvent * event = [EKEvent eventWithEventStore: store];
        event.calendar=store.defaultCalendarForNewEvents;

        if(action[@"title"]) {
            event.title=action[@"title"];
        } else {
            NSLog(@"No title, could not add to calendar");
            return;
        }

        if(action[@"timeZone"]) {
            event.timeZone=[NSTimeZone timeZoneWithAbbreviation: action[@"timeZone"]];
        }

        if(action[@"startDate"]) {
            event.startDate = [formatter dateFromString: action[@"startDate"]];
        } else {
            NSLog(@"No startDate, could not add to calendar");
        }
        
        if(action[@"endDate"]) {
            event.endDate = [formatter dateFromString: action[@"endDate"]];
        } else {
            NSLog(@"No endDate, could not add to calendar");
        }
        
        if(action[@"description"]) {
            event.notes=action[@"description"];
        }
        
        
        if([action[@"interactive"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
                controller.event = event;
                controller.eventStore = store;
                controller.editViewDelegate = self;
                
                UIWindow * window = [[UIApplication sharedApplication] keyWindow];
                [window.rootViewController presentViewController:controller animated:TRUE completion:nil];
            });
        } else {
            NSError * saveError = nil;
            BOOL success = [store saveEvent: event span:EKSpanThisEvent commit:TRUE error:&saveError];
            if(saveError) {
                NSLog(@"Could not save to calendar %@", [saveError localizedDescription]);
            }
            if(!success) {
                NSLog(@"Could not save to calendar");
            }
        }
        
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    switch (action) {
        case  EKEventEditViewActionCanceled:
            NSLog(@"Event was not added to calendar");
            break;
        case EKEventEditViewActionSaved:
            NSLog(@"Event was added to calendar");
            break;
        case EKEventEditViewActionDeleted:
            NSLog(@"Event was deleted from calendar");
            break;
            
        default:
            break;
    }
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    [window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
