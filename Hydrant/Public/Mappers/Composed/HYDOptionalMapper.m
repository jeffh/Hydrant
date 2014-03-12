#import "HYDOptionalMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN
id<HYDMapper> HYDMapOptionally(void)
{
    return HYDMapOptionallyTo(HYDMapIdentity());
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyTo(id<HYDMapper> mapper)
{
    return HYDMapOptionallyWithDefault(mapper, nil);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(id defaultValue)
{
    return HYDMapOptionallyWithDefault(HYDMapIdentity(), defaultValue);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(id<HYDMapper> mapper, id defaultValue)
{
    return HYDMapOptionallyWithDefault(mapper, defaultValue, defaultValue);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(id<HYDMapper> mapper, id defaultValue, id reverseDefaultValue)
{
    return HYDMapNonFatallyWithDefault(HYDMapNotNullFrom(mapper), defaultValue, reverseDefaultValue);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefaultFactory(HYDValueBlock defaultValueFactory)
{
    return HYDMapOptionallyWithDefaultFactory(HYDMapIdentity(), defaultValueFactory);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory)
{
    return HYDMapOptionallyWithDefaultFactory(mapper, defaultValueFactory, defaultValueFactory);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory, HYDValueBlock reverseDefaultValueFactory)
{
    return HYDMapNonFatallyWithDefaultFactory(HYDMapNotNullFrom(mapper), defaultValueFactory, reverseDefaultValueFactory);
}
