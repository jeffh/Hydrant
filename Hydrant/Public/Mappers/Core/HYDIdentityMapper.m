#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDAccessor.h"
#import "HYDDefaultAccessor.h"
#import "HYDKeyAccessor.h"


@interface HYDIdentityMapper : NSObject <HYDMapper>

- (instancetype)init;

@end


@implementation HYDIdentityMapper

- (instancetype)init
{
    return self = [super init];
}

#pragma mark - HYDMapper

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
    static HYDIdentityMapper *HYDIdentityMapperSharedInstance__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HYDIdentityMapperSharedInstance__ = [[HYDIdentityMapper alloc] init];
    });
    return HYDIdentityMapperSharedInstance__;
}
