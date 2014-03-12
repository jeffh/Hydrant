#import "HYDStringToNumberMapper.h"
#import "HYDMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN
id<HYDMapper> HYDMapStringToDecimalNumber(void)
{
    return HYDMapStringToNumber(HYDMapIdentity(), NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper)
{
    return HYDMapStringToNumber(mapper, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(NSNumberFormatterStyle numberFormatterStyle)
{
    return HYDMapStringToNumber(HYDMapIdentity(), numberFormatterStyle);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatterStyle;
    return HYDMapStringToNumber(mapper, numberFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(NSNumberFormatter *numberFormatter)
{
    return HYDMapStringToNumber(HYDMapIdentity(), numberFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)
{
    return HYDMapStringToObjectByFormatter(mapper, numberFormatter);
}
