#import "HYDStringToObjectFormatterMapper.h"


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *dstKey);

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToNumberByFormat(NSString *dstKey, NSNumberFormatterStyle numberFormatterStyle);

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToNumberByFormatter(NSString *dstKey, NSNumberFormatter *formatter);
