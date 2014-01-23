#import "HYDBase.h"
#import "HYDStringToObjectFormatterMapper.h"


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToURL(NSString *destinationKey);

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);