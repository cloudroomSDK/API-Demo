//
//  CloudroomPlatformView.h
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2021/11/8.
//

#import <Foundation/Foundation.h>
#import <Flutter/FlutterPlatformViews.h>
#import <CloudroomVideoSDK_IOS/CloudroomVideoSDK_IOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface CloudroomPlatformView : NSObject<FlutterPlatformView>

- (instancetype)initWithRect:(CGRect)rect viewID:(int64_t)viewID viewType:(NSString *)viewType;

- (UIView *)getUIView;

@end

NS_ASSUME_NONNULL_END
