//
//  YYPeekLocation.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYThing.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYPeekLocation : YYThing

@property (nonatomic, readonly) BOOL canReply;
@property (nonatomic, readonly) BOOL canReport;
@property (nonatomic, readonly) BOOL canVote;

@property (nonatomic, readonly) id   delta;
@property (nonatomic, readonly) BOOL isInactive;
@property (nonatomic, readonly) BOOL isFictional;
@property (nonatomic, readonly) BOOL isLocal;
@property (nonatomic, readonly) BOOL isMediaEnabled;

@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;
@property (nonatomic, readonly) NSDictionary *location;

@end

NS_ASSUME_NONNULL_END
