//
//  CloudroomPlatformView.m
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2021/11/8.
//

#import "CloudroomPlatformView.h"

@interface CloudroomPlatformView ()

@property (nonatomic, strong) UIView *uiView;
@property (nonatomic, assign) int64_t viewID;
@property (nonatomic, copy) NSString *viewType;

@end

@implementation CloudroomPlatformView

- (instancetype)initWithRect:(CGRect)rect viewID:(int64_t)viewID viewType:(NSString *)viewType {
    self = [super init];
    if (self) {
        _viewID = viewID;
        _viewType = viewType;
        if ([viewType isEqualToString:@"platformview"]) {
            _uiView = [[CLCameraView alloc] initWithFrame:rect];

        } else if ([viewType isEqualToString:@"screenshareview"]) {
            _uiView = [[CLShareView alloc] initWithFrame:rect];
            
        } else if ([viewType isEqualToString:@"mediaview"]) {
            _uiView = [[CLMediaView alloc] initWithFrame:rect];
            
        } else {
            
        }
    }

    NSLog(@"[CloudroomPlatformView] [init] UIView:%p, viewType:%@", self.uiView, viewType);
    
    return self;
}

- (UIView *)getUIView {
    return self.uiView;
}

- (void)dealloc {
    NSLog(@"[CloudroomPlatformView] [dispose] UIView:%p", self.uiView);
}

# pragma mark - Flutter Platform View Delegate

- (UIView *)view {
    return self.uiView;
}

@end
