#import "HYDStringToURLMapper.h"
#import "HYDMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDURLFormatter.h"

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURL(void)
{
    return HYDMapStringToURLFrom(HYDMapIdentity());
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLFrom(id<HYDMapper> mapper)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDMapStringToObjectByFormatter(mapper, formatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURL(NSArray *allowedSchemes)
{
    return HYDMapStringToURLOfScheme(HYDMapIdentity(), allowedSchemes);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLFrom(id<HYDMapper> mapper, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapStringToObjectByFormatter(mapper, formatter);
}

#pragma mark - Pending Deprecation

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLOfScheme(NSArray *allowedSchemes)
{
    return HYDMapStringToURLOfScheme(HYDMapIdentity(), allowedSchemes);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapStringToObjectByFormatter(mapper, formatter);
}

