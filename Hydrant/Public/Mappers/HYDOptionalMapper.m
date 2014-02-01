#import "HYDOptionalMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionally(NSString *destinationKey)
{
    return HYDMapOptionally(HYDMapIdentity(destinationKey));
}


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionally(id<HYDMapper> mapper)
{
    return HYDMapOptionallyWithDefault(mapper, nil);
}


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(NSString *destinationKey, id defaultValue)
{
    return HYDMapOptionallyWithDefault(HYDMapIdentity(destinationKey), defaultValue);
}


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(id<HYDMapper> mapper, id defaultValue)
{
    return HYDMapOptionallyWithDefaultAndReversedDefault(mapper, defaultValue, defaultValue);
}


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefaultAndReversedDefault(id<HYDMapper> mapper, id defaultValue, id reverseDefaultValue)
{
    return HYDMapNonFatallyWithDefaultAndReversedDefault(HYDMapNotNull(mapper), defaultValue, reverseDefaultValue);
}
