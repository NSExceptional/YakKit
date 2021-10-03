//
//  YYClient+Misc.h
//  Pods
//
//  Created by Tanner on 11/13/15.
//
//

#import "YYClient.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYClient (Misc)

#pragma mark Misc
- (void)logEvent:(NSString *)event completion:(nullable YYErrorBlock)completion;
- (void)refreshLocate:(nullable YYErrorBlock)completion;
- (void)contactUs:(NSString *)topic message:(NSString *)message email:(NSString *)email completion:(nullable YYErrorBlock)completion;

- (void)authenticateForLayer:(NSString *)nonce completion:(YYStringBlock)completion;

@end

NS_ASSUME_NONNULL_END
