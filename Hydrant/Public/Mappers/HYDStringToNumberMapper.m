#import "HYDStringToNumberMapper.h"


HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *destKey)
{
    return HYDStringToNumber(destKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *destKey, NSNumberFormatterStyle numberFormaterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormaterStyle;
    return HYDStringToNumber(destKey, numberFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return HYDStringToObjectWithFormatter(destKey, numberFormatter);
}