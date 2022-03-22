//
//  CloudroomCommonType.h
//  CloudroomVideoSDK_IOS
//
//  Created by cloudroom on 2018/11/22.
//  Copyright © 2018年 lake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudroomVideoSDK_IOS/CloudroomVideoSDK_Def.h>

/* 网盘 */
typedef NS_ENUM(NSInteger, CoverState)
{
    CS_uploading = 0,
    CS_pending,
    CS_converting,
};

typedef NS_ENUM(NSInteger, COVER_STATE) { CS_UPLOADING=0, CS_PENDING, CS_CONVERTING};

CRVSDK_EXPORT
@interface DiskCoverState : NSObject
@property (nonatomic, assign) COVER_STATE state;
@property (nonatomic, assign) int param;
@end


typedef NS_ENUM(uint8_t, YWOrientation) {
    YWOrientationPortrait               = 0, //No rotation
    YWOrientationLandscapeLeft          = 1, //Rotate 90 degrees clockwise
    YWOrientationPortraitUpsideDown     = 2, //Rotate 180 degrees
    YWOrientationLandscapeRight         = 3, //Rotate 270 degrees clockwise
};

CRVSDK_EXPORT
@interface FileInfo : NSObject
@property (nonatomic, assign) short ownerID;
@property (nonatomic, assign) int size;
@property (nonatomic, assign) int orgSize;
@property (nonatomic, assign) int status;
@property (nonatomic, copy) NSString* ownerName;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* orgFileName;
@property (nonatomic, copy) NSString* md5;
@property (nonatomic, copy) NSString* ctime;
@end


CRVSDK_EXPORT
@interface DiskSummary : NSObject
@property (nonatomic, assign) int confDiskLimit;    //KB
@property (nonatomic, assign) int confDiskUsed;    //KB
@end
