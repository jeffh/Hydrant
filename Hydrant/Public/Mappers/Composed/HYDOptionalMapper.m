#import "HYDOptionalMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionally(NSString *destinationKey)
{
    return HYDMapOptionally(HYDMapIdentity(destinationKey));
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionally(id<HYDMapper> mapper)
{
    return HYDMapOptionallyWithDefault(mapper, nil);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(NSString *destinationKey, id defaultValue)
{
    return HYDMapOptionallyWithDefault(HYDMapIdentity(destinationKey), defaultValue);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(id<HYDMapper> mapper, id defaultValue)
{
    return HYDMapOptionallyWithDefault(mapper, defaultValue, defaultValue);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(id<HYDMapper> mapper, id defaultValue, id reverseDefaultValue)
{
    return HYDMapNonFatallyWithDefault(HYDMapNotNull(mapper), defaultValue, reverseDefaultValue);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefaultFactory(NSString *destinationKey, HYDValueBlock defaultValueFactory)
{
    return HYDMapOptionallyWithDefaultFactory(HYDMapIdentity(destinationKey), defaultValueFactory);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory)
{
    return HYDMapOptionallyWithDefaultFactory(mapper, defaultValueFactory, defaultValueFactory);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory, HYDValueBlock reverseDefaultValueFactory)
{
    return HYDMapNonFatallyWithDefaultFactory(HYDMapNotNull(mapper), defaultValueFactory, reverseDefaultValueFactory);
}
