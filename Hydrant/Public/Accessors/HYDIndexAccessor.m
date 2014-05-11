#import "HYDIndexAccessor.h"
#import "HYDAccessor.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDIndexSetter.h"


@interface HYDIndexAccessor : NSObject <HYDAccessor>

@property (nonatomic, copy) NSArray *indicies;
@property (nonatomic, strong) HYDIndexSetter *setter;

- (id)initWithIndicies:(NSArray *)indicies setter:(HYDIndexSetter *)setter;

@end


@implementation HYDIndexAccessor

- (id)initWithIndicies:(NSArray *)indicies setter:(HYDIndexSetter *)setter
{
    self = [super init];
    if (self) {
        self.indicies = indicies;
        self.setter = setter;
    }
    return self;
}

#pragma mark - HYDAccessor

- (NSArray *)valuesFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    if (![sourceObject respondsToSelector:@selector(objectAtIndex:)] ||
            ![sourceObject respondsToSelector:@selector(count)]) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorGetViaAccessorFailed
                                              sourceObject:sourceObject
                                            sourceAccessor:self
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:nil]);
        return nil;
    }

    NSUInteger count = [sourceObject count];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.indicies.count];
    for (NSNumber *indexNumber in self.indicies) {
        NSUInteger index = [indexNumber unsignedIntegerValue];
        id value = [NSNull null];
        if (index < count) {
            value = [sourceObject objectAtIndex:index];
        }
        [values addObject:value];
    }
    return values;
}

- (HYDError *)setValues:(NSArray *)values onObject:(id)destinationObject
{
    NSError *internalError = nil;
    if (values.count != self.indicies.count) {
        internalError = [self internalErrorWithFormat:@"Values to set do not match the same count as the values provided: expected %lu, got %lu",
                                                      (unsigned long long)self.indicies.count,
                                                      (unsigned long long)values.count];
    }

    if (![destinationObject respondsToSelector:@selector(setObject:atIndex:)]) {
        internalError = [self internalErrorWithFormat:@"Destination object does not support setting values (%@)",
                                                      NSStringFromSelector(@selector(setObject:atIndex:))];
    }

    if (internalError) {
        return [HYDError errorWithCode:HYDErrorSetViaAccessorFailed
                          sourceObject:nil
                        sourceAccessor:nil
                     destinationObject:destinationObject
                   destinationAccessor:self
                               isFatal:YES
                      underlyingErrors:@[internalError]];
    }

    for (NSUInteger i = 0, c = self.indicies.count; i < c; i++) {
        NSUInteger indexToSet = [self.indicies[i] unsignedIntegerValue];
        [self.setter setValue:values[i] atIndex:indexToSet inObject:destinationObject];
    }
    return nil;
}

- (NSArray *)fieldNames
{
    return [self.indicies valueForKey:@"stringValue"];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<HYDIndexAccessor: %@>", self.indicies];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    return [self.indicies isEqual:[other indicies]];
}

- (NSUInteger)hash
{
    return [self.indicies hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Private

- (NSError *)internalErrorWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [NSError errorWithDomain:NSInvalidArgumentException
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey: reason}];
}

@end


HYD_EXTERN
id<HYDAccessor> HYDAccessIndiciesFromArray(NSArray *indicies)
{
    NSCAssert([indicies firstObject], @"Got nil instead of an NSNumber. Did you mean @0?");
    NSCAssert(HYDIsArrayOf(indicies, [NSNumber class]), @"%s expected argument to be an array of NSNumbers, got: %@",
             __PRETTY_FUNCTION__, indicies);

    return [[HYDIndexAccessor alloc] initWithIndicies:indicies setter:[HYDIndexSetter new]];
}

