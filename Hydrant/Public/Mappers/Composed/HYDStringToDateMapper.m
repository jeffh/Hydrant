#import "HYDStringToDateMapper.h"
#import "HYDMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDFirstMapper.h"
#import "HYDConstants.h"
#import "HYDDotNetDateFormatter.h"
#import "HYDThreadMapper.h"


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(NSString *formatString)
{
    return HYDMapStringToDate(HYDMapIdentity(), formatString);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(id<HYDMapper> mapper, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return HYDMapStringToDate(mapper, dateFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(NSDateFormatter *dateFormatter)
{
    return HYDMapStringToDate(HYDMapIdentity(), dateFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
{
    return HYDMapStringToObjectByFormatter(mapper, dateFormatter);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToAnyDate(void)
{
    return HYDMapFirst(HYDMapStringToDate(HYDDateFormatRFC3339_milliseconds),
                       HYDMapStringToDate(HYDDateFormatRFC3339),
                       HYDMapStringToDate([HYDDotNetDateFormatter new]),
                       HYDMapStringToDate(HYDDateFormatRFC822),
                       HYDMapStringToDate(HYDDateFormatRFC822_day),
                       HYDMapStringToDate(HYDDateFormatRFC822_day_gmt),
                       HYDMapStringToDate(HYDDateFormatRFC822_day_seconds),
                       HYDMapStringToDate(HYDDateFormatRFC822_day_seconds_gmt),
                       HYDMapStringToDate(HYDDateFormatRFC822_seconds),
                       HYDMapStringToDate(HYDDateFormatRFC822_seconds_gmt),
                       HYDMapStringToDate(HYDDateFormatRFC822_gmt));
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToAnyDate(id<HYDMapper> innerMapper)
{
    return HYDMapThread(innerMapper, HYDMapStringToAnyDate());
}
