#import "HYDStringToDateMapper.h"
#import "HYDMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(NSString *destinationKey, NSString *formatString)
{
    return HYDMapStringToDate(HYDMapIdentity(destinationKey), formatString);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(id<HYDMapper> mapper, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return HYDMapStringToDate(mapper, dateFormatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(NSString *destinationKey, NSDateFormatter *dateFormatter)
{
    return HYDMapStringToDate(HYDMapIdentity(destinationKey), dateFormatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
{
    return HYDMapStringToObjectByFormatter(mapper, dateFormatter);
}

