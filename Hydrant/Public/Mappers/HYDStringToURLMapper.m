#import "HYDStringToURLMapper.h"
#import "HYDURLFormatter.h"


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToURL(NSString *destinationKey)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDStringToObjectWithFormatter(destinationKey, formatter);
}


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDStringToObjectWithFormatter(destinationKey, formatter);
}
