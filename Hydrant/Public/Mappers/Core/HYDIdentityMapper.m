#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDAccessor.h"
#import "HYDDefaultAccessor.h"
#import "HYDKeyAccessor.h"


@interface HYDIdentityMapper ()

@end


@implementation HYDIdentityMapper

- (instancetype)init
{
    return self = [super init];
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return sourceObject;
}

- (id<HYDMapper>)reverseMapper
{
    return self;
}

@end

HYD_EXTERN
HYDIdentityMapper *HYDMapIdentity(void)
{
    return [[HYDIdentityMapper alloc] init];
}
