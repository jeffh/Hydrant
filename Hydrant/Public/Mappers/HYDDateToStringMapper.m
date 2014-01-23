#import "HYDDateToStringMapper.h"
#import "HYDError.h"


HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDDateToString(dstKey, dateFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return HYDObjectToStringWithFormatter(dstKey, dateFormatter);
}