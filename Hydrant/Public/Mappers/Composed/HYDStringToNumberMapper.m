#import "HYDStringToNumberMapper.h"
#import "HYDMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey)
{
    return HYDMapStringToNumber(destinationKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(id<HYDMapper> mapper)
{
    return HYDMapStringToNumber(mapper, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatterStyle numberFormatterStyle)
{
    return HYDMapStringToNumber(HYDMapIdentity(destinationKey), numberFormatterStyle);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatterStyle;
    return HYDMapStringToNumber(mapper, numberFormatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatter *numberFormatter)
{
    return HYDMapStringToNumber(HYDMapIdentity(destinationKey), numberFormatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)
{
    return HYDMapStringToObjectByFormatter(mapper, numberFormatter);
}
