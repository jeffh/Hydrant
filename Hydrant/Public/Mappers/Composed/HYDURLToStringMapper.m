#import "HYDURLToStringMapper.h"
#import "HYDMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDURLFormatter.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToString(void)
{
    return HYDMapURLToStringFrom(HYDMapIdentity());
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringFrom(id<HYDMapper> mapper)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDMapObjectToStringByFormatter(mapper, formatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToString(NSArray *allowedSchemes)
{
    return HYDMapURLToStringOfScheme(HYDMapIdentity(), allowedSchemes);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringFrom(id<HYDMapper> mapper, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapObjectToStringByFormatter(mapper, formatter);
}

#pragma mark - Pending Deprecation

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(NSArray *allowedSchemes)
{
    return HYDMapURLToStringOfScheme(HYDMapIdentity(), allowedSchemes);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapObjectToStringByFormatter(mapper, formatter);
}
