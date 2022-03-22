//
//  NSNull+NullCast.m
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2022/3/1.
//

#import "NSNull+NullCast.h"

@implementation NSNull (NullCast)

- (float)floatValue {
    return 0.0;
}

- (double)doubleValue {
    return 0.0;
}

- (int)intValue {
    return 0;
}

- (short)shortValue {
    return 0;
}

- (NSInteger)integerValue {
    return 0;
}

@end
