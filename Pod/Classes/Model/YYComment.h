//
//  YYComment.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYVotable.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYComment : YYVotable

@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSString *authorIdentifier;
@property (nonatomic, readonly) NSString *yakIdentifier;

@property (nonatomic, readonly) BOOL     isOP;
@property (nonatomic, readonly) NSString *backgroundIdentifier;
@property (nonatomic, readonly) NSString *overlayIdentifier;
@property (nonatomic, readonly) NSString *textStyle;

@end

NS_ASSUME_NONNULL_END