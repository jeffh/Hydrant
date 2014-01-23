#import "HYDStringToObjectFormatterMapper.h"


HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);
