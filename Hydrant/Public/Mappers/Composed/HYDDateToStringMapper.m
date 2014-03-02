#import "HYDDateToStringMapper.h"
#import "HYDMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *destinationKey, NSString *formatString)
{
    return HYDMapDateToString(HYDMapIdentity(destinationKey), formatString);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(id<HYDMapper> mapper, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return HYDMapDateToString(mapper, dateFormatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *destinationKey, NSDateFormatter *dateFormatter)
{
    return HYDMapObjectToStringByFormatter(destinationKey, dateFormatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
{
    return HYDMapObjectToStringByFormatter(mapper, dateFormatter);
}
