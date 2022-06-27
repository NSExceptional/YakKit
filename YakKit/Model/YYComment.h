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

@property (nonatomic, readonly) BOOL isOP;
@property (nonatomic, readonly) NSString *yakIdentifier; // yakID

#pragma mark Deprecated
@property (nonatomic, readonly) NSString *commentID;
@property (nonatomic, readonly) NSString *relevantAuthorIdentifier; // authorIdentifier
@property (nonatomic, readonly) NSString *body; // text
@property (nonatomic, readonly) BOOL deleted;

@end

NS_ASSUME_NONNULL_END
