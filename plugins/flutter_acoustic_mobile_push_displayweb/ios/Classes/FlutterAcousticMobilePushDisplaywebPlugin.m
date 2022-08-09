#import "FlutterAcousticMobilePushDisplaywebPlugin.h"
#import "WebViewController.h"
#import <AcousticMobilePush/AcousticMobilePush.h>

@implementation FlutterAcousticMobilePushDisplaywebPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_acoustic_mobile_push_displayweb"
            binaryMessenger:[registrar messenger]];
  FlutterAcousticMobilePushDisplaywebPlugin* instance = [[FlutterAcousticMobilePushDisplaywebPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  if ([@"displayWebAction" isEqualToString:call.method]) {
    NSString* url = call.arguments;
    [self performAction: url];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)performAction:(NSString*)url
{
    WebViewController * viewController = [[WebViewController alloc] initWithURL:[NSURL URLWithString: url]];
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    if(controller) {
        [controller presentViewController:viewController animated:TRUE completion:nil];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performAction: url];
        });
    }
}

@end
