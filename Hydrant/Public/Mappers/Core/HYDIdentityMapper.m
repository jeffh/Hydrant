#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDAccessor.h"
#import "HYDKeyAccessor.h"


@interface HYDIdentityMapper ()

@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;

@end


@implementation HYDIdentityMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    self = [super init];
    if (self) {
        self.destinationAccessor = destinationAccessor;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return sourceObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return [[[self class] alloc] initWithDestinationAccessor:destinationAccessor];
}

@end


HYD_EXTERN
HYD_OVERLOADED
HYDIdentityMapper *HYDMapIdentity(NSString *destinationKey)
{
    return HYDMapIdentity(HYDAccessKey(destinationKey));
}


HYD_EXTERN
HYD_OVERLOADED
HYDIdentityMapper *HYDMapIdentity(id<HYDAccessor> destinationAccessor)
{
    return [[HYDIdentityMapper alloc] initWithDestinationAccessor:destinationAccessor];
}
