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
    
    return self;
}

+ (NSArray *)arrayOfModelsFromJSONArray:(NSArray *)json {
    NSParameterAssert(json.count);
    
    NSMutableArray *things = [NSMutableArray array];
    for (NSDictionary *obj in json)
        [things addObject:[[[self class] alloc] initWithDictionary:obj]];
    
    return things.copy;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    [NSException raise:NSInternalInconsistencyException format:@"Subclasses must not call super on this method."];
    return nil;
}

+ (NSValueTransformer *)yy_intBoolTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return @(value.integerValue);
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    }];
}

@end
