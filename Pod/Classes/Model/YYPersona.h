//
//  YYPersona.h
//  Pods
//
//  Created by Tanner on 7/28/16.
//
//

#import "YYThing.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYPersona : YYThing

@property (nonatomic, readonly, nullable) NSString  *bio;
@property (nonatomic, readonly          ) NSString  *handle;
@property (nonatomic, readonly          ) NSInteger yakarma;
@property (nonatomic, readonly          ) BOOL      hasPhoto;

/// @code{
///   account: username,
///   key: social_media_type,
///   url: self_explainatory,
///   network: 1
/// }@endcode
@property (nonatomic, readonly) NSDictionary *socialMedia;

#pragma mark Useless
@property (nonatomic, readonly) BOOL hasBio;
@property (nonatomic, readonly) BOOL hasSocialMedia;

@end

NS_ASSUME_NONNULL_END
