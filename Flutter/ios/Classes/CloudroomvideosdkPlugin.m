#import "CloudroomvideosdkPlugin.h"
#import "CloudroomVideoSDKMethodHandler.h"
#import "CloudroomPlatformViewFactory.h"
#import "CloudroomVideoSDKEventHandler.h"

@interface CloudroomvideosdkPlugin () <FlutterStreamHandler>
@property (nonatomic, strong) id<FlutterPluginRegistrar> registrar;
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) FlutterEventChannel *eventChannel;
@property (nonatomic, strong) FlutterEventSink eventSink;
@end
@implementation CloudroomvideosdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"cr_flutter_sdk"
            binaryMessenger:[registrar messenger]];
    CloudroomvideosdkPlugin* instance = [[CloudroomvideosdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    instance.registrar = registrar;
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"cr_flutter_sdk_event_handler" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
    instance.eventChannel = eventChannel;
    // Register platform view factory
    [registrar registerViewFactory:[CloudroomPlatformViewFactory sharedInstance] withId:@"cr_flutter_sdk_view"];
}

#pragma mark - Handle Event Sink
/**
 * Sets up an event stream and begin emitting events.
 *
 * Invoked when the first listener is registered with the Stream associated to
 * this channel on the Flutter side.
 *
 * @param arguments Arguments for the stream.
 * @param events A callback to asynchronously emit events. Invoke the
 *     callback with a `FlutterError` to emit an error event. Invoke the
 *     callback with `FlutterEndOfEventStream` to indicate that no more
 *     events will be emitted. Any other value, including `nil` are emitted as
 *     successful events.
 * @return A FlutterError instance, if setup fails.
 */
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    self.eventSink = events;
    [CloudroomVideoSDKEventHandler shareInstance].eventSink = self.eventSink;
    NSLog(@"[FlutterEventSink] [onListen] set eventSink: %p", _eventSink);
    return nil;
}
/**
 * Tears down an event stream.
 *
 * Invoked when the last listener is deregistered from the Stream associated to
 * this channel on the Flutter side.
 *
 * The channel implementation may call this method with `nil` arguments
 * to separate a pair of two consecutive set up requests. Such request pairs
 * may occur during Flutter hot restart.
 *
 * @param arguments Arguments for the stream.
 * @return A FlutterError instance, if teardown fails.
 */
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    NSLog(@"[FlutterEventSink] [onCancel] set eventSink: %p to nil", _eventSink);
    self.eventSink = nil;
    return nil;
}
#pragma mark - Handle Method Call
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:result:", call.method]);
    if (![[CloudroomVideoSDKMethodHandler shareInstance] respondsToSelector:selector]) {
        NSLog(@"[handleMethodCall] Unrecognized selector: %@", call.method);
    result(FlutterMethodNotImplemented);
        return;
  }
    NSMethodSignature *signature = [[CloudroomVideoSDKMethodHandler shareInstance] methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = [CloudroomVideoSDKMethodHandler shareInstance];
    invocation.selector = selector;
    [invocation setArgument:&call atIndex:2];
    [invocation setArgument:&result atIndex:3];
    [invocation invoke];
}

@end
