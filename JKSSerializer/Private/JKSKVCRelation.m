#import "JKSKVCRelation.h"

@implementation JKSKVCRelation

+ (instancetype)relationFromArray:(NSArray *)arraySyntax
{
    NSAssert(arraySyntax.count == 3, @"relation array must be size of 3 [destinationKey, fromClass, destinationClass]");
    BOOL isArray = [arraySyntax[1] isKindOfClass:[NSArray class]];
    return [[self alloc] initWithDestinationKey:arraySyntax[0]
                                      fromClass:(isArray ? arraySyntax[1][0] : arraySyntax[1])
                                        isArray:isArray
                             toDestinationClass:arraySyntax[2]];
}

- (id)initWithDestinationKey:(NSString *)key
                   fromClass:(Class)objectClass
                     isArray:(BOOL)isArray
          toDestinationClass:(Class)destinationClass
{
    self = [super init];
    if (self){
        self.destinationKey = key;
        self.objectClass = objectClass;
        self.destinationClass = destinationClass;
        self.isArrayOfClass = isArray;
    }
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)serializeObject:(id)value sourceKey:sourceKeyPath serializer:(id<JKSSerializer>)serializer
{
    id output = nil;
    value = [value valueForKey:sourceKeyPath];
    if (![serializer isNullObject:value] && self.isArrayOfClass) {
        NSMutableArray *collectionValue = [NSMutableArray new];
        for (id item in value) {
            id object = [serializer serializeObjectOfClass:self.destinationClass fromSourceObject:item];
            [collectionValue addObject:object];
        }
        output = collectionValue;
    } else {
        output = [serializer serializeObjectOfClass:self.destinationClass fromSourceObject:value];
    }
    return output;
}

- (id)deserializeObject:(id)value serializer:(id<JKSSerializer>)serializer
{
    id output = nil;
    value = [value valueForKey:self.destinationKey];
    if (![serializer isNullObject:value] && self.isArrayOfClass) {
        NSMutableArray *collectionValue = [NSMutableArray new];
        for (id item in value) {
            id object = [serializer deserializeObjectOfClass:self.objectClass fromSourceObject:item];
            [collectionValue addObject:object];
        }
        output = collectionValue;
    } else {
        output = [serializer deserializeObjectOfClass:self.objectClass fromSourceObject:value];
    }
    return output;
}

@end
