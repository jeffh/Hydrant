#import "HYDUUIDToString.h"
#import "HYDMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDUUIDFormatter.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapUUIDToString(NSString *destinationKey)
{
    return HYDMapUUIDToString(HYDMapIdentity(destinationKey));
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapUUIDToString(id<HYDMapper> mapper)
{
    return HYDMapObjectToStringByFormatter(mapper, [[HYDUUIDFormatter alloc] init]);
}
