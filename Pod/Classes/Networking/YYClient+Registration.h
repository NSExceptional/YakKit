//
//  YYClient+Registration.h
//  Pods
//
//  Created by Tanner on 4/18/16.
//
//

#import "YYClient.h"
#import "Mantle/Mantle.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYClient (Registration)

#pragma mark Registration
/** Creates a new user by generating a new user identifier.
 @discussion The old user information (id, object, configuration) will be discarded.
 @warning Do not call this method without first providing a location and region. */
- (void)registerNewUser:(ErrorBlock)completion;
/// Completion block takes a YYNicknamePolicy object.
- (void)nicknamePolicy:(ResponseBlock)completion;
/// Completion takes a boolean indicating success.
- (void)checkHandleAvailability:(NSString *)handle completion:(BooleanBlock)completion;
/** Begins phone registration. Completion takes a token to be used in the next step.
 @param phoneNumber The phone number to send a verification text to. Must be formatted like (XXX) XXX-XXXX
 @param prefix The country code prefix to the phone number.
 @param country ie "USA" */
- (void)startVerification:(NSString *)phoneNumber countryPrefix:(NSString *)prefix country:(NSString *)country completion:(StringBlock)completion;
/** Completes phone registration. Completion takes a boolean indicating success.
 @param code The code sent via text message from the first step.
 @param token The token returned from the first step. */
- (void)endVerification:(NSString *)code token:(NSString *)token completion:(BooleanBlock)completion;

@end


@interface YYNicknamePolicy : MTLModel <MTLJSONSerializing>

- (id)initWithDictionary:(NSDictionary *)json;

@property (nonatomic, readonly) NSInteger minDigits;
@property (nonatomic, readonly) NSInteger minAlpha;
@property (nonatomic, readonly) NSInteger minLength;
@property (nonatomic, readonly) NSInteger maxLength;
@property (nonatomic, readonly) NSInteger maxOther;

@end

NS_ASSUME_NONNULL_END
