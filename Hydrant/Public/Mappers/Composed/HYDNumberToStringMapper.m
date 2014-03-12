#import "HYDNumberToStringMapper.h"
#import "HYDMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN
id<HYDMapper> HYDMapDecimalNumberToString(void)
{
    return HYDMapNumberToString(NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper> mapper)
{
    return HYDMapNumberToString(mapper, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(NSNumberFormatterStyle numberFormatStyle)
{
    return HYDMapNumberToString(HYDMapIdentity(), numberFormatStyle);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return HYDMapNumberToString(mapper, numberFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(NSNumberFormatter *numberFormatter)
{
    return HYDMapNumberToString(HYDMapIdentity(), numberFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)
{
    return HYDMapObjectToStringByFormatter(mapper, numberFormatter);
}

