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

@property (nonatomic, readonly) NSInteger replyCount;

#pragma mark Deprecated
@property (nonatomic, readonly) BOOL      isReadOnly;
@property (nonatomic, readonly          ) NSString *title;
@property (nonatomic, readonly, nullable) NSString *handle;

@end

NS_ASSUME_NONNULL_END
