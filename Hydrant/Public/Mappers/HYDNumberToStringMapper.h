#import "HYDBase.h"
#import "HYDObjectToStringFormatterMapper.h"


HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destKey);

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDNumberToStringByFormat(NSString *destKey, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDNumberToStringByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter);
