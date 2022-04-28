//
//  YYYak.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYVotable.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYYak : YYVotable

@property (nonatomic, readonly          ) NSString *title;
@property (nonatomic, readonly, nullable) NSString *handle;
@property (nonatomic, readonly          ) NSString *authorIdentifier;

@property (nonatomic, readonly) BOOL      canUpvote;
@property (nonatomic, readonly) BOOL      canDownvote;
@property (nonatomic, readonly) BOOL      canReply;
@property (nonatomic, readonly) BOOL      isReadOnly;
@property (nonatomic, readonly) BOOL      isReyaked;
@property (nonatomic, readonly) NSInteger replyCount;

@property (nonatomic, readonly) double      latitude;
@property (nonatomic, readonly) double      longitude;
@property (nonatomic, readonly) NSDictionary *location;
@property (nonatomic, readonly) BOOL         hideLocationPin;
@property (nonatomic, readonly) NSInteger    locationDisplayStyle;
@property (nonatomic, readonly) NSString     *locationName;

@property (nonatomic, readonly          ) BOOL  hasMedia;
@property (nonatomic, readonly, nullable) NSURL *thumbnailURL;
@property (nonatomic, readonly, nullable) NSURL *mediaURL;
@property (nonatomic, readonly          ) NSInteger mediaWidth;
@property (nonatomic, readonly          ) NSInteger mediaHeight;

@property (nonatomic, readonly) NSInteger type;

@end

NS_ASSUME_NONNULL_END
