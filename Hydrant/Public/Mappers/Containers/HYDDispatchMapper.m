#import "HYDDispatchMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"

HYD_INLINE
NSArray *HYDMappingTuple(NSArray *mappingTuples)
{
    for (NSArray *mappingTuple in mappingTuples) {
        NSCAssert(mappingTuple.count == 3, @"Mapping tuple should have EXACTLY three items [sourceClass, mapper, destinationClass]");
        NSCAssert([mappingTuple[1] conformsToProtocol:@protocol(HYDMapper)], @"the second element ofr the mapping tuple should be a HYDMapper (got %@)", mappingTuple[1]);
    }
    return mappingTuples;
}

@interface HYDDispatchMapper ()

@property (nonatomic, copy) NSArray *mappingTuple;

@end


@implementation HYDDispatchMapper

- (instancetype)initWithMappingTuple:(NSArray *)mappingTuple
{
    self = [super init];
    if (self) {
        self.mappingTuple = HYDMappingTuple(mappingTuple);
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    for (NSArray *mappingTuple in self.mappingTuple) {
        Class targetClass = mappingTuple[0];
        id<HYDMapper> mapper = mappingTuple[1];
        if ([sourceObject isKindOfClass:targetClass]) {
            return [mapper objectFromSourceObject:sourceObject error:error];
        }
    }

    HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectType
                                          sourceObject:sourceObject
                                        sourceAccessor:nil
                                     destinationObject:nil
                                   destinationAccessor:nil
                                               isFatal:YES
                                      underlyingErrors:nil]);
    return nil;
}

- (id<HYDMapper>)reverseMapper
{
    NSMutableArray *reversedMappingTuple = [NSMutableArray arrayWithCapacity:self.mappingTuple.count];
    for (NSArray *mappingTuple in self.mappingTuple) {
        Class sourceClass = mappingTuple.firstObject;
        id<HYDMapper> mapper = mappingTuple[1];
        Class destinationClass = mappingTuple.lastObject;
        [reversedMappingTuple addObject:@[destinationClass, [mapper reverseMapper], sourceClass]];
    }
    return [[HYDDispatchMapper alloc] initWithMappingTuple:reversedMappingTuple];
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDispatch(NSArray *mappingTuple)
{
    return [[HYDDispatchMapper alloc] initWithMappingTuple:mappingTuple];
}
