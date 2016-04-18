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

+ (NSArray *)arrayOfModelsFromJSONArray:(NSArray *)json;

+ (NSValueTransformer *)yy_intBoolTransformer;

@property (nonatomic, readonly) NSString *identifier;

@end

NS_ASSUME_NONNULL_END


