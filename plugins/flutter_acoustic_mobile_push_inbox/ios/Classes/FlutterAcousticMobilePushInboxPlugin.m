#import "FlutterAcousticMobilePushInboxPlugin.h"
#import <AcousticMobilePush/AcousticMobilePush.h>
static FlutterMethodChannel * channelIn;
static FlutterMethodChannel * channelOut;
@interface FlutterAcousticMobilePushInboxPlugin  ()
@property NSString * attribution;
@property NSNumber * mailingId;
@property NSUUID * messageId;
@property UIViewController <MCETemplateDisplay> * displayViewController;
@end
@implementation FlutterAcousticMobilePushInboxPlugin
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    channelIn = [FlutterMethodChannel
                 methodChannelWithName:@"flutter_acoustic_mobile_push_inbox"
                 binaryMessenger:[registrar messenger]];
    channelOut = [FlutterMethodChannel
                  methodChannelWithName:@"flutter_acoustic_mobile_push_inbox_receiver"
                  binaryMessenger:[registrar messenger]];
    
    FlutterAcousticMobilePushInboxPlugin* instance = [[FlutterAcousticMobilePushInboxPlugin alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channelIn];
    [registrar addMethodCallDelegate:instance channel:channelOut];
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"registerInboxComponent" isEqualToString:call.method]) {
        NSString* module = call.arguments[@"module"];
        self.inboxActionModule = module;
        // TODO: remove in future patch - potentially not needed for iOS (test to confirm)
        [MCEActionRegistry.sharedInstance registerTarget: self withSelector:@selector(openInboxMessageAction:payload:) forAction:@"openInboxMessage"];
    } else if ([@"inboxMessageCount" isEqualToString:call.method]) {
        int unreadCount = [[MCEInboxDatabase sharedInstance] unreadMessageCount];
        int messageCount = [[MCEInboxDatabase sharedInstance] messageCount];
        result(@[ @{@"messages": @(messageCount), @"unread": @(unreadCount)} ]);
    } else if ([@"deleteInboxMessage" isEqualToString:call.method]) {
        NSString* inboxMessageId = call.arguments;
        MCEInboxMessage * inboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId:inboxMessageId];
        if(inboxMessage) {
            inboxMessage.isDeleted=TRUE;
        }
    } else if ([@"readInboxMessage" isEqualToString:call.method]) {
        NSString* inboxMessageId = call.arguments;
        NSLog(@"INBOX MESSAGE ID: %@", inboxMessageId);
        MCEInboxMessage * inboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId:inboxMessageId];
        if(inboxMessage) {
            inboxMessage.isRead=TRUE;
        }
    } else if ([@"unreadInboxMessage" isEqualToString:call.method]) {
        NSString* inboxMessageId = call.arguments;
        NSLog(@"INBOX MESSAGE ID: %@", inboxMessageId);
        MCEInboxMessage * inboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId:inboxMessageId];
        if(inboxMessage) {
            inboxMessage.isRead=FALSE;
        }
    } else if ([@"syncInboxMessage" isEqualToString:call.method]) {
        if (MCESdk.sharedInstance.config.appKey.length == 0) {
            return NSLog(@"No App Key");
        }
        [MCEInboxQueueManager.sharedInstance syncInbox];
        
        NSMutableArray* messages = [[MCEInboxDatabase sharedInstance] inboxMessagesAscending: YES];
        NSMutableArray* messageMap = [NSMutableArray array];
        
        for (MCEInboxMessage* message in messages) {
            [messageMap addObject: [self inboxMessageToJson: message]];
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: messageMap options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [channelIn invokeMethod: @"InboxMessages" arguments: jsonString result: nil];
        //    result(@"syncMesssage function is called");
    } else if ([@"listInboxMessages" isEqualToString:call.method]) {
        BOOL direction = [call.arguments[@"direction"] boolValue];
        NSArray * inboxMessages = [MCEInboxDatabase.sharedInstance inboxMessagesAscending:direction];
        NSMutableArray * jsonInboxMessages = [NSMutableArray array];
        for (MCEInboxMessage * inboxMessage in inboxMessages) {
            [jsonInboxMessages addObject: [self inboxMessageToJson:inboxMessage]];
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: jsonInboxMessages options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        result(jsonString);
        
        //    result(@[jsonInboxMessages]);
    } else if ([@"clickInboxAction" isEqualToString:call.method]) {
        NSString* stringAction = call.arguments[@"action"];
        NSError * err;
        NSData *data =[stringAction dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * action;
        if(data!=nil){
         action = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        }
        NSString* inboxMessageId = call.arguments[@"inboxMessageId"];
        MCEInboxMessage *inboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId:inboxMessageId];
        
        NSDictionary * payload = @{@"mce": [NSMutableDictionary dictionary]};
        if(inboxMessage.attribution) {
            payload[@"mce"][@"attribution"] = inboxMessage.attribution;
        }
        if(inboxMessage.mailingId) {
            payload[@"mce"][@"mailingId"] = inboxMessage.mailingId;
        }
        
        NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
        if(inboxMessage.richContentId) {
            attributes[@"richContentId"] = inboxMessage.richContentId;
        }
        if(inboxMessage.inboxMessageId) {
            attributes[@"inboxMessageId"] = inboxMessage.inboxMessageId;
        }
        
        [MCEActionRegistry.sharedInstance performAction:action forPayload:payload source:InboxSource attributes:attributes userText:nil];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}
-(NSDictionary*)inboxMessageToJson:(MCEInboxMessage*)inboxMessage {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    

    if(inboxMessage.isRead) {
        dictionary[@"isRead"] = [NSNumber numberWithBool: inboxMessage.isRead];
    }
    if(inboxMessage.isDeleted) {
        dictionary[@"isDeleted"] = [NSNumber numberWithBool: inboxMessage.isDeleted];
    }
    if(inboxMessage.isExpired) {
        dictionary[@"isExpired"] = [NSNumber numberWithBool: inboxMessage.isExpired];
    }
    if(inboxMessage.content) {
        dictionary[@"content"] = inboxMessage.content;
    }
    if(inboxMessage.expirationDate) {
        dictionary[@"expirationDate"] = [NSNumber numberWithDouble: [inboxMessage.expirationDate timeIntervalSince1970] * 1000];
    }
    if(inboxMessage.sendDate) {
        dictionary[@"sendDate"] = [NSNumber numberWithDouble: [inboxMessage.sendDate timeIntervalSince1970] * 1000];
    }
    if(inboxMessage.templateName) {
        dictionary[@"templateName"] = inboxMessage.templateName;
    }
    if(inboxMessage.inboxMessageId) {
        dictionary[@"inboxMessageId"] = inboxMessage.inboxMessageId;
    }
    if(inboxMessage.richContentId) {
        dictionary[@"richContentId"] = inboxMessage.richContentId;
    }
    if(inboxMessage.attribution) {
        dictionary[@"attribution"] = inboxMessage.attribution;
    }
    if(inboxMessage.mailingId) {
        dictionary[@"mailingId"] = inboxMessage.mailingId;
    }
    
    //    NSLog(@"Dic --> %@", dictionary);
    return dictionary;
}
-(void)openInboxMessageAction: (NSDictionary*)action payload: (NSDictionary*)payload {
    
    MCEInboxMessage * inboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId: action[@"inboxMessageId"]];
    if(inboxMessage) {
        
        NSString * inboxMessageId = inboxMessage.inboxMessageId;
        [channelOut invokeMethod: @"inboxMessageNotification" arguments: inboxMessageId result: nil];
    } else {
        [MCEInboxQueueManager.sharedInstance getInboxMessageId:action[@"inboxMessageId"] completion:^(MCEInboxMessage *inboxMessage, NSError *error) {
            if(error) {
                NSLog(@"Could not get inbox message from database %@", error);
                return;
            }
            
            NSString * inboxMessageId = inboxMessage.inboxMessageId;
            [channelOut invokeMethod: @"inboxMessageNotification" arguments: inboxMessageId result: nil];
        }];
    }
}
-(void)showInboxMessage:(NSDictionary*)action payload:(NSDictionary*)payload {
    self.attribution = nil;
    self.mailingId = nil;
    self.messageId = nil;
    if(payload[@"mce"]) {
        self.attribution = payload[@"mce"][@"attribution"];
        if([payload[@"mce"][@"mailingId"] respondsToSelector:@selector(isEqualToNumber:)]) {
            self.mailingId = payload[@"mce"][@"mailingId"];
        } else if ([payload[@"mce"][@"mailingId"] respondsToSelector:@selector(isEqualToString:)]) {
            NSString * string = payload[@"mce"][@"mailingId"];
            double value = [string doubleValue];
            self.mailingId = @(value);
        }
    }
    
    if(!action[@"inboxMessageId"])
    {
        NSLog(@"Could not showInboxMessage, no inboxMessageId included %@", action);
        return;
    }
    
    MCEInboxMessage * inboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId: action[@"inboxMessageId"]];
    if(inboxMessage) {
        [self showInboxMessage: inboxMessage];
    } else {
        [MCEInboxQueueManager.sharedInstance getInboxMessageId:action[@"inboxMessageId"] completion:^(MCEInboxMessage *inboxMessage, NSError *error) {
            if(error) {
                NSLog(@"Could not get inbox message from database %@", error);
                return;
            }
            [self showInboxMessage: inboxMessage];
        }];
    }
}
-(void)showInboxMessage: (MCEInboxMessage *)inboxMessage
{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(showInboxMessage:) withObject:inboxMessage waitUntilDone:NO];
        return;
    }
    
    self.displayViewController = (UIViewController<MCETemplateDisplay> *) [[MCETemplateRegistry sharedInstance] viewControllerForTemplate: inboxMessage.templateName];
    
    if(!self.displayViewController) {
        NSLog(@"Could not showInboxMessage, %@ template not registered", inboxMessage.templateName);
        return;
    }
    
    [self.displayViewController setLoading];
    
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    
    if([controller respondsToSelector: @selector(viewControllers)]) {
        UISplitViewController * splitController = (UISplitViewController *) controller;
        controller = [[splitController viewControllers] lastObject];
    }
    
    if([controller respondsToSelector:@selector(pushViewController:animated:)]) {
        UINavigationController * navController = (UINavigationController*) controller;
        [navController pushViewController: self.displayViewController animated: true];
    } else {
        [controller presentViewController:(UIViewController*)self.displayViewController animated:TRUE completion:nil];
    }
    
    [self displayRichContent: inboxMessage];
}
-(void)displayRichContent: (MCEInboxMessage*)inboxMessage {
    inboxMessage.isRead = TRUE;
    [[MCEEventService sharedInstance] recordViewForInboxMessage:inboxMessage attribution: self.attribution mailingId: self.mailingId];
    
    self.displayViewController.inboxMessage = inboxMessage;
    [self.displayViewController setContent];
}
+(void)registerPlugin {
    NSLog(@"registerPlugin");
    [MCEActionRegistry.sharedInstance registerTarget:[self sharedInstance] withSelector: @selector(showInboxMessage:payload:) forAction: @"openInboxMessage"];
}
@end
