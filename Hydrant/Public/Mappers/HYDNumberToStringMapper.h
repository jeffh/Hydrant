#import "HYDBase.h"
#import "HYDObjectToStringFormatterMapper.h"


HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destKey);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destKey, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destKey, NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(2);
