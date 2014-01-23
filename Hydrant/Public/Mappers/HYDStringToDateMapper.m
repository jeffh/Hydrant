#import "HYDStringToDateMapper.h"


HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDStringToDate(dstKey, dateFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return HYDStringToObjectWithFormatter(dstKey, dateFormatter);
}