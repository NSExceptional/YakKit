//
//  YYThing.m
//  Pods
//
//  Created by Tanner on 11/10/15.
//
//

#import "YYThing.h"


@implementation YYThing

- (id)initWithDictionary:(NSDictionary *)json {
    NSParameterAssert(json.allKeys.count > 0);
    NSError *error = nil;
    self = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:json error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSParameterAssert((!error && self) || (error && !self));
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object class] == [self class])
        return [self isEqualToThing:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToThing:(YYThing *)thing {
    return [thing.identifier isEqualToString:self.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

+ (NSArray *)arrayOfModelsFromJSONArray:(NSArray *)json {
    NSParameterAssert(json);
    
    NSMutableArray *things = [NSMutableArray array];
    for (NSDictionary *obj in json)
        [things addObject:[[[self class] alloc] initWithDictionary:obj]];
    
    return things.copy;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    [NSException raise:NSInternalInconsistencyException format:@"Subclasses must not call super on this method."];
    return nil;
}

+ (NSValueTransformer *)yy_stringToNumberTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return @(value.integerValue);
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError **error) {
        return value;
    }];
}

+ (NSValueTransformer *)yy_UTCDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *ts, BOOL *success, NSError **error) {
        return [NSDate dateWithTimeIntervalSince1970:ts.doubleValue];
    } reverseBlock:^id(NSDate *ts, BOOL *success, NSError **error) {
        return @(ts.timeIntervalSince1970).stringValue;
    }];
}

@end
