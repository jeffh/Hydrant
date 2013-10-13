#import "JKSKeyValueSerializer.h"
#import <objc/runtime.h>
#import "JKSMapper.h"
#import "JKSKVCMapper.h"
#import "JKSKVCRelation.h"
#import "JKSKVCField.h"

@interface JKSKeyValueSerializer () <JKSSerializer>
@property (strong, nonatomic) NSMutableDictionary *classSerializers;
@property (strong, nonatomic) NSMutableDictionary *classDeserializers;
@end

@implementation JKSKeyValueSerializer

static JKSKeyValueSerializer *serializer__;

+ (instancetype)sharedSerializer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializer__ = [self new];
    });
    return serializer__;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.classSerializers = [NSMutableDictionary new];
        self.classDeserializers = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerClass:(Class)aClass withMapping:(NSDictionary *)dictionary
{
    NSString *className = NSStringFromClass(aClass);
    JKSKVCMapper *mapper = [JKSKVCMapper mapperWithDSLMapping:dictionary];
    self.classSerializers[className] = mapper;
    self.classDeserializers[className] = mapper;
}

- (void)registerClass:(Class)aClass withDeserializationMapping:(NSDictionary *)dictionary
{
    self.classDeserializers[NSStringFromClass(aClass)] = [JKSKVCMapper mapperWithDSLMapping:dictionary];
}

- ( void)registerClass:(Class)aClass withSerializationMapping:(NSDictionary *)dictionary
{
    self.classSerializers[NSStringFromClass(aClass)] = [JKSKVCMapper mapperWithDSLMapping:dictionary];
}

#pragma mark - <JKSSerializer>

- (BOOL)isNullObject:(id)object
{
    return object == nil || object == [NSNull null] || object == self.nullObject || [self.nullObject isEqual:object];
}

- (void)serializeToObject:(id)object fromObject:(id)sourceObject
{
    id<JKSMapper> mapper = self.classSerializers[NSStringFromClass([sourceObject class])];
    [mapper serializeToObject:object fromObject:sourceObject serializer:self];
}

- (void)deserializeToObject:(id)object fromObject:(id)sourceObject
{
    id<JKSMapper> mapper = self.classDeserializers[NSStringFromClass([object class])];
    [mapper deserializeToObject:object fromObject:sourceObject serializer:self];
}

- (id)serializeObjectOfClass:(Class)class fromSourceObject:(id)sourceObject
{
    if ([self isNullObject:sourceObject]) {
        return self.nullObject;
    } else {
        id object = [class new];
        [self serializeToObject:object fromObject:sourceObject];
        return object;
    }
}

- (id)deserializeObjectOfClass:(Class)class fromSourceObject:(id)sourceObject
{
    if ([self isNullObject:sourceObject]) {
        return self.nullObject;
    } else {
        id object = [class new];
        [self deserializeToObject:object fromObject:sourceObject];
        return object;
    }
}

#pragma mark - Private

- (NSDictionary *)processMapping:(NSDictionary *)dictionary
{
    NSMutableDictionary *mapping = [dictionary mutableCopy];
    for (NSString *key in dictionary) {
        id processorType = dictionary[key];
        if ([processorType isKindOfClass:[NSArray class]]) {
            mapping[key] = [JKSKVCRelation relationFromArray:processorType];
        } else if ([processorType isKindOfClass:[NSString class]]) {
            mapping[key] = [[JKSKVCField alloc] initWithName:dictionary[key]];
        }
    }
    return mapping;
}

@end
