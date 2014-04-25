#import "HYDConstants.h"

NSString *HYDDateFormatRFC3339 = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
NSString *HYDDateFormatRFC3339_milliseconds = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";

NSString *HYDDateFormatRFC822_day_seconds_gmt = @"EEE, d MMM yyyy HH:mm:ss zzz";
NSString *HYDDateFormatRFC822_day_gmt = @"EEE, d MMM yyyy HH:mm zzz";
NSString *HYDDateFormatRFC822_day_seconds = @"EEE, d MMM yyyy HH:mm:ss";
NSString *HYDDateFormatRFC822_day = @"EEE, d MMM yyyy HH:mm";
NSString *HYDDateFormatRFC822_seconds_gmt = @"d MMM yyyy HH:mm:ss zzz";
NSString *HYDDateFormatRFC822_gmt = @"d MMM yyyy HH:mm zzz";
NSString *HYDDateFormatRFC822_seconds = @"d MMM yyyy HH:mm:ss";
NSString *HYDDateFormatRFC822 = @"d MMM yyyy HH:mm";

id HYDRootMapper = nil;

NSString *HYDErrorDomain = @"HYDErrorDomain";

NSString *HYDIsFatalKey = @"HYDIsFatal";
NSString *HYDUnderlyingErrorsKey = @"HYDUnderlyingErrors";
NSString *HYDSourceObjectKey = @"HYDSourceObject";
NSString *HYDSourceAccessorKey = @"HYDSourceAccessor";
NSString *HYDDestinationObjectKey = @"HYDDestinationObjectPath";
NSString *HYDDestinationAccessorKey = @"HYDDestinationAccessor";
