//
//  YYClient+Yaks.h
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYClient (Yaks)

#pragma mark Getting yak feeds
- (void)getLocalYaks:(ArrayBlock)completion;
- (void)getLocalHotYaks:(ArrayBlock)completion;
- (void)getLocalTopYaks:(ArrayBlock)completion;
- (void)getYaksInPeek:(YYPeekLocation *)location hot:(BOOL)hot completion:(ArrayBlock)completion;

#pragma mark Getting comments
- (void)getCommentsForYak:(YYYak *)yak completion:(ArrayBlock)completion;

@end

NS_ASSUME_NONNULL_END
