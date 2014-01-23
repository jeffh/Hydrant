#import "HYDStringToObjectFormatterMapper.h"


HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *dstKey);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *dstKey, NSNumberFormatterStyle numberFormatterStyle);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *dstKey, NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);
