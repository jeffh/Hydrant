#import "HYDNumberToStringMapper.h"
#import "HYDError.h"
#import "HYDStringToNumberMapper.h"
#import "HYDObjectToStringFormatterMapper.h"


HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destKey)
{
    return HYDNumberToString(destKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return HYDNumberToString(destKey, numberFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return HYDObjectToStringWithFormatter(destKey, numberFormatter);
}