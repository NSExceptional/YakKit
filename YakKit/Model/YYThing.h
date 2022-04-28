//
//  YYThing.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import <Mantle/Mantle.h>


#define MTLStringToNumberJSONTransformer(property) + (NSValueTransformer *) property##JSONTransformer { \
return [self yy_stringToNumberTransformer]; }

NS_ASSUME_NONNULL_BEGIN

@interface YYThing : MTLModel <MTLJSONSerializing>

- (id)initWithDictionary:(NSDictionary *)json;

+ (NSArray *)arrayOfModelsFromJSONArray:(NSArray *)json;

+ (NSValueTransformer *)yy_stringToNumberTransformer;
+ (NSValueTransformer *)yy_UTCDateTransformer;

@property (nonatomic, readonly) NSString *identifier;

@end

NS_ASSUME_NONNULL_END


