#import "HYDEnumMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDAccessor.h"
#import "HYDKeyAccessor.h"


@interface HYDEnumMapper ()

@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic) NSDictionary *mapping;

@end


@implementation HYDEnumMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationAccessor = destinationAccessor;
        self.mapping = mapping;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    id result = self.mapping[sourceObject];
    if (!result) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:self.destinationAccessor
                                                   isFatal:YES
                                          underlyingErrors:nil]);
        return nil;
    }
    return result;
}

- (instancetype)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    NSMutableDictionary *reverseMapping = [[NSMutableDictionary alloc] initWithCapacity:self.mapping.count];
    for (id key in self.mapping) {
        id value = self.mapping[key];
        reverseMapping[value] = key;
    }
    return [[HYDEnumMapper alloc] initWithDestinationAccessor:destinationAccessor mapping:reverseMapping];
}

@end


HYD_EXTERN
HYDEnumMapper *HYDMapEnum(NSString *destinationKey, NSDictionary *mapping)
{
    return [[HYDEnumMapper alloc] initWithDestinationAccessor:HYDAccessKey(destinationKey)
                                                      mapping:mapping];
}
