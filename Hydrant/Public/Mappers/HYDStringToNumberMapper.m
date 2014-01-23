#import "HYDStringToNumberMapper.h"


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *destKey)
{
    return HYDStringToNumberByFormat(destKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToNumberByFormat(NSString *destKey, NSNumberFormatterStyle numberFormaterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormaterStyle;
    return HYDStringToNumberByFormatter(destKey, numberFormatter);
}

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToNumberByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return HYDStringToObjectWithFormatter(destKey, numberFormatter);
}