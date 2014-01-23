#import "HYDBase.h"
#import "HYDObjectToStringFormatterMapper.h"


HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDDateToStringWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter);