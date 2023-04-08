//
//  YYThing.h
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

@import Mantle;


#define MTLStringToNumberJSONTransformer(property) + (NSValueTransformer *) property##JSONTransformer { \
return [self yy_stringToNumberTransformer]; }

NS_ASSUME_NONNULL_BEGIN

@interface YYThing : MTLModel <MTLJSONSerializing>

- (id)initWithDictionary:(NSDictionary *)json;

+ (instancetype)fromJSON:(NSDictionary *)json;
+ (NSArray *)arrayOfModelsFromJSONArray:(NSArray *)json;

- (void)postInit;

/// Subclasses may override. Nil by default.
///
/// A key path to use to initialize self from the given JSON. Useful if
/// your array contains a single level abstraction before all the data, i.e.
/// maybe you would want to skip 'node' here: { "node": { "id": 5, "foo": "bar" } }
@property (nonatomic, readonly, nullable, class) NSString *selfJSONKeyPath;

+ (NSValueTransformer *)yy_stringToNumberTransformer;
+ (NSValueTransformer *)yy_UTCDateTransformer;
+ (NSValueTransformer *)yy_stringDateTransformer;

@property (nonatomic, readonly, class) NSDateFormatter *dateFormatter;

@property (nonatomic, readonly) NSString *identifier;

@end

NS_ASSUME_NONNULL_END


