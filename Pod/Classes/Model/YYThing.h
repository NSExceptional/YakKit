//
//  YYThing.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import <Mantle/Mantle.h>


#define MTLBoolStringJSONTransformer(property) + (NSValueTransformer *) property##JSONTransformer { \
return [self yy_intBoolTransformer]; }

NS_ASSUME_NONNULL_BEGIN

@interface YYThing : MTLModel <MTLJSONSerializing>

- (id)initWithDictionary:(NSDictionary *)json;

+ (NSArray *)arrayOfModelsFromJSONArray:(NSArray *)json;

+ (NSValueTransformer *)yy_intBoolTransformer;
+ (NSValueTransformer *)yy_UTCDateTransformer;

@property (nonatomic, readonly) NSString *identifier;

@end

NS_ASSUME_NONNULL_END


