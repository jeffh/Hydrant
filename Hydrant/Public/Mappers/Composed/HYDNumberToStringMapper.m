#import "HYDNumberToStringMapper.h"
#import "HYDMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey)
{
    return HYDMapNumberToString(destinationKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper> mapper)
{
    return HYDMapNumberToString(mapper, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatterStyle numberFormatStyle)
{
    return HYDMapNumberToString(HYDMapIdentity(destinationKey), numberFormatStyle);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return HYDMapNumberToString(mapper, numberFormatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatter *numberFormatter)
{
    return HYDMapNumberToString(HYDMapIdentity(destinationKey), numberFormatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)
{
    return HYDMapObjectToStringByFormatter(mapper, numberFormatter);
}

