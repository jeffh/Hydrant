#import "HYDURLToStringMapper.h"
#import "HYDMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDURLFormatter.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToString(NSString *destinationKey)
{
    return HYDMapURLToString(HYDMapIdentity(destinationKey));
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToString(id<HYDMapper> mapper)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDMapObjectToStringByFormatter(mapper, formatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    return HYDMapURLToStringOfScheme(HYDMapIdentity(destinationKey), allowedSchemes);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapObjectToStringByFormatter(mapper, formatter);
}
