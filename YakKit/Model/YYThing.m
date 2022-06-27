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
    
    if (self.class.selfJSONKeyPath) {
        json = json[self.class.selfJSONKeyPath] ?: json;
    }
    
    self = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:json error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    NSParameterAssert((!error && self) || (error && !self));
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object class] == [self class]) {
        return [self isEqualToThing:object];
    }
    
    return [super isEqual:object];
}

- (BOOL)isEqualToThing:(YYThing *)thing {
    return [thing.identifier isEqualToString:self.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

+ (instancetype)fromJSON:(NSDictionary *)json {
    return [[self alloc] initWithDictionary:json];
}

+ (NSArray *)arrayOfModelsFromJSONArray:(NSArray *)json {
    NSParameterAssert(json);
    
    NSMutableArray *things = [NSMutableArray array];
    for (NSDictionary *obj in json) {
        [things addObject:[self fromJSON:obj]];
    }
    
    return things.copy;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    static NSMutableDictionary<NSString*, NSDictionary*> *classesToMappings = nil;
    if (!classesToMappings) {
        classesToMappings = [NSMutableDictionary dictionary];
    }

    NSString *key = NSStringFromClass(self);
    NSDictionary *mapping = classesToMappings[key];
    if (!mapping) {
        mapping = [self computedJSONKeyPathsByPropertyKey];
        classesToMappings[key] = mapping;
    }

    return mapping;
}

+ (NSDictionary *)computedJSONKeyPathsByPropertyKey {
    NSSet<NSString*> *properties = [self propertyKeys];
    NSMutableDictionary *defaultMapping = [NSMutableDictionary dictionary];
    for (NSString *property in properties) {
        defaultMapping[property] = property;
    }

    return defaultMapping.copy;
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

+ (NSValueTransformer *)yy_stringDateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError **error) {
        return [[self dateFormatter] dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError **error) {
        return [[self dateFormatter] stringFromDate:date];
    }];
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [NSDateFormatter new];
        sharedFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ";
//        sharedFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    });
    
    return sharedFormatter;
}

@end
