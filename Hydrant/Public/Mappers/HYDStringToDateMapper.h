#import "HYDStringToObjectFormatterMapper.h"


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToDateWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter);
