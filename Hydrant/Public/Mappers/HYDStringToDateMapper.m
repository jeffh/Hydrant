#import "HYDStringToDateMapper.h"


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDStringToDateWithFormatter(dstKey, dateFormatter);
}

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToDateWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return HYDStringToObjectWithFormatter(dstKey, dateFormatter);
}