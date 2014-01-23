#import "HYDDateToStringMapper.h"
#import "HYDError.h"


HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDDateToStringWithFormatter(dstKey, dateFormatter);
}

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDDateToStringWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return HYDObjectToStringWithFormatter(dstKey, dateFormatter);
}