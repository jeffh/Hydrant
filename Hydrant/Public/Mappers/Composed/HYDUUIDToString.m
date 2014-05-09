#import "HYDUUIDToString.h"
#import "HYDMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDUUIDFormatter.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN
id<HYDMapper> HYDMapUUIDToString()
{
    return HYDMapUUIDToStringFrom(HYDMapIdentity());
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapUUIDToStringFrom(id<HYDMapper> mapper)
{
    return HYDMapObjectToStringByFormatter(mapper, [[HYDUUIDFormatter alloc] init]);
}
