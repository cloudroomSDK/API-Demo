//
//  NSObject+Json.h
//  cr_flutter_sdk
//
//  Created by YunWu01 on 2021/10/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Json)

- (NSString*)toJSONString;
+ (id)objectWithJSONString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
