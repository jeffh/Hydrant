#import "HYDStringToUUIDMapper.h"
#import "HYDMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDUUIDFormatter.h"


HYD_EXTERN
id<HYDMapper> HYDMapStringToUUID(void)
{
    return HYDMapStringToUUIDFrom(HYDMapIdentity());
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToUUIDFrom(id<HYDMapper> mapper)
{
    return HYDMapStringToObjectByFormatter(mapper, [[HYDUUIDFormatter alloc] init]);
}
