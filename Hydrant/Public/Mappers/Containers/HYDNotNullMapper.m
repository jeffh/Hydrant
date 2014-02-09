#import "HYDNotNullMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"


@interface HYDNotNullMapper ()

@property (strong, nonatomic) id<HYDMapper> mapper;

@end


@implementation HYDNotNullMapper

- (id)initWithMapper:(id<HYDMapper>)mapper
{
    self = [super init];
    if (self) {
        self.mapper = mapper;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    HYDError *innerError = nil;
    id resultingObject = [self.mapper objectFromSourceObject:sourceObject error:&innerError];

    if (innerError) {
        HYDSetObjectPointer(error, innerError);
        return resultingObject;
    }

    if (!resultingObject) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidResultingObjectType
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:self.destinationAccessor
                                                   isFatal:YES
                                          underlyingErrors:nil]);
    }

    return resultingObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return [[[self class] alloc] initWithMapper:[self.mapper reverseMapperWithDestinationAccessor:destinationAccessor]];
}

- (id<HYDAccessor>)destinationAccessor
{
    return self.mapper.destinationAccessor;
}

@end


HYD_EXTERN
HYD_OVERLOADED
HYDNotNullMapper *HYDMapNotNull(NSString *destinationKey)
{
    return HYDMapNotNull(HYDMapIdentity(destinationKey));
}


HYD_EXTERN
HYD_OVERLOADED
HYDNotNullMapper *HYDMapNotNull(id<HYDMapper> mapper)
{
    return [[HYDNotNullMapper alloc] initWithMapper:mapper];
}
