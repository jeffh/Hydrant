#import "HYDBase.h"
#import "HYDObjectToStringFormatterMapper.h"


HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);