#import "HYDNumberToStringMapper.h"
#import "HYDError.h"
#import "HYDStringToNumberMapper.h"
#import "HYDObjectToStringFormatterMapper.h"


HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destKey)
{
    return HYDNumberToStringByFormat(destKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDNumberToStringByFormat(NSString *destKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return HYDNumberToStringByFormatter(destKey, numberFormatter);
}

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDNumberToStringByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return HYDObjectToStringWithFormatter(destKey, numberFormatter);
}