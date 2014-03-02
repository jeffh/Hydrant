#import "HYDStringToURLMapper.h"
#import "HYDMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDURLFormatter.h"

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToURL(NSString *destinationKey)
{
    return HYDMapStringToURL(HYDMapIdentity(destinationKey));
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToURL(id<HYDMapper> mapper)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDMapStringToObjectByFormatter(mapper, formatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    return HYDMapStringToURLOfScheme(HYDMapIdentity(destinationKey), allowedSchemes);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToURLOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapStringToObjectByFormatter(mapper, formatter);
}

