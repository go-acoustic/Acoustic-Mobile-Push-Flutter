#import <Flutter/Flutter.h>

@protocol MCEActionProtocol <NSObject>
@optional
- (void)configureAlertTextField:(UITextField *)textField;
@end

@interface FlutterAcousticMobilePushInboxPlugin : NSObject <FlutterPlugin, MCEActionProtocol>
@property NSString *inboxActionModule;
+ (void)registerPlugin;
@end
