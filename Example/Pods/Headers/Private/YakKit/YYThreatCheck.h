//
//  YYThreatCheck.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import <Mantle/Mantle.h>


NS_ASSUME_NONNULL_BEGIN

@interface YYThreatCheck : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) BOOL allowContinue;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSArray<NSString *> *expressions;

@end

NS_ASSUME_NONNULL_END