#import "HYDKeyPathAccessor.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDFactory.h"
#import "HYDObjectFactory.h"
#import "HYDFunctions.h"
#import "HYDError.h"


@interface HYDKeyPathAccessor ()

@property (copy, nonatomic) NSArray *fieldNames;
@property (strong, nonatomic) id<HYDFactory> factory;

@end


@implementation HYDKeyPathAccessor

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithKeyPaths:(NSArray *)keyPaths
{
    self = [super init];
    if (self) {
        self.fieldNames = keyPaths;
        self.factory = [[HYDObjectFactory alloc] init];
    }
    return self;
}

#pragma mark - <NSObject>

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[self class]] && [self.fieldNames isEqual:[(HYDKeyPathAccessor *)object fieldNames]];
}

- (NSUInteger)hash
{
    return self.fieldNames.hash;
}

- (NSString *)description
{
    if (self.fieldNames.count == 1) {
        return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), self.fieldNames[0]];
    } else {
        return [NSString stringWithFormat:@"<%@: [%@]>", NSStringFromClass([self class]), [self.fieldNames componentsJoinedByString:@", "]];
    }
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return self; // I don't mutate
}

#pragma mark - <HYDAccessor>

- (NSArray *)valuesFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    if (!sourceObject) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorGetViaAccessorFailed
                                              sourceObject:sourceObject
                                            sourceAccessor:self
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:nil]);
        return nil;
    }

    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.fieldNames.count];
    for (NSString *keyPath in self.fieldNames) {
        if ([self canReadKeyPath:keyPath fromSourceObject:sourceObject]) {
            [values addObject:[sourceObject valueForKeyPath:keyPath] ?: [NSNull null]];
        } else {
            /* We should return an error, but for backwards compatibility...
            HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorGetViaAccessorFailed
                                                  sourceObject:sourceObject
                                                sourceAccessor:self
                                             destinationObject:nil
                                           destinationAccessor:nil
                                                       isFatal:YES
                                              underlyingErrors:nil]);
             */
            return nil;
        }
    }
    return values;
}

- (HYDError *)setValues:(NSArray *)values onObject:(id)destinationObject
{
    if (values.count != self.fieldNames.count) {
        return [HYDError errorWithCode:HYDErrorSetViaAccessorFailed
                          sourceObject:nil
                        sourceAccessor:nil
                     destinationObject:destinationObject
                   destinationAccessor:self
                               isFatal:YES
                      underlyingErrors:nil];
    }

    NSUInteger index = 0;
    for (NSString *keyPath in self.fieldNames) {
        // for easier debuggability, we're opting to potentially explode here
        [self setValue:values[index] ofClass:[destinationObject class] forKeyPath:keyPath onObject:destinationObject];
        ++index;
    }
    return nil;
}

#pragma mark - Private

- (BOOL)canReadKeyPath:(NSString *)keyPath fromSourceObject:(id)sourceObject
{
    NSArray *keyComponents = [keyPath componentsSeparatedByString:@"."];
    id keyTarget = sourceObject;
    for (NSString *key in keyComponents) {
        if (![self hasKey:key onObject:keyTarget]) {
            return NO;
        }
        keyTarget = [keyTarget valueForKey:key];
    }
    return YES;
}

- (void)setValue:(id)value ofClass:(Class)destinationClass forKeyPath:(NSString *)keyPath onObject:(id)object
{
    // for backwards compat: don't assign NSNull if it should be doing this...
    if ([[NSNull null] isEqual:value] /* && ![self requiresNSNullForClass:destinationClass] */) {
        return;
    }

    NSArray *keyComponents = [keyPath componentsSeparatedByString:@"."];
    NSString *keyToMutate = keyComponents.lastObject;

    id keyTarget = object;
    for (NSString *key in keyComponents) {
        if (keyToMutate == key) {
            break;
        }
        id previousTarget = keyTarget;
        keyTarget = [keyTarget valueForKey:key];
        if (!keyTarget) {
            keyTarget = [self.factory newObjectOfClass:destinationClass];
            [previousTarget setValue:keyTarget forKey:key];
        }
    }

    [keyTarget setValue:value forKey:keyToMutate];
}

- (BOOL)hasKey:(NSString *)key onObject:(id)target
{
    if (!target) {
        return NO;
    }

    if ([target respondsToSelector:@selector(objectForKey:)]) {
        if ([target valueForKey:key]) {
            return YES;
        }
    }

    HYDClassInspector *inspector = [HYDClassInspector inspectorForClass:[target class]];
    for (HYDProperty *property in inspector.allProperties) {
        if ([property.name isEqual:key]) {
            return YES;
        }
    }
    return NO;
}

@end


HYD_EXTERN
HYDKeyPathAccessor *HYDAccessKeyPathFromArray(NSArray *keyPaths)
{
    NSCAssert([keyPaths firstObject],
              @"%s expects at least one keyPath. Are you missing a string?", __PRETTY_FUNCTION__);
    NSCAssert(HYDIsArrayOf(keyPaths, [NSString class]),
              @"%s expected keyPaths to be an array of strings: got %@",
              __PRETTY_FUNCTION__, [keyPaths valueForKey:@"class"]);
    return [[HYDKeyPathAccessor alloc] initWithKeyPaths:keyPaths];
}
