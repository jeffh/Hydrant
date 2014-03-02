#import "HYDStringToUUIDMapper.h"
#import "HYDMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDUUIDFormatter.h"


HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToUUID(NSString *destinationKey)
{
    return HYDMapStringToUUID(HYDMapIdentity(destinationKey));
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToUUID(id<HYDMapper> mapper)
{
    return HYDMapStringToObjectByFormatter(mapper, [[HYDUUIDFormatter alloc] init]);
}
