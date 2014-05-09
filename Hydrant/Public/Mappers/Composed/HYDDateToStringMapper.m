#import "HYDDateToStringMapper.h"
#import "HYDMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDIdentityMapper.h"


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(NSString *formatString)
{
    return HYDMapDateToString(HYDMapIdentity(), formatString);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(id<HYDMapper> mapper, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return HYDMapDateToString(mapper, dateFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(NSDateFormatter *dateFormatter)
{
    return HYDMapObjectToStringByFormatter(HYDMapIdentity(), dateFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
{
    return HYDMapObjectToStringByFormatter(mapper, dateFormatter);
}
