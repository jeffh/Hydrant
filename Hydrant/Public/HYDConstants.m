#import "HYDConstants.h"

NSString *HYDDateFormatRFC3339 = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
id HYDRootMapper = nil;

NSString *HYDErrorDomain = @"HYDErrorDomain";
const NSInteger HYDErrorInvalidSourceObjectValue = 1;
const NSInteger HYDErrorInvalidSourceObjectType = 2;
const NSInteger HYDErrorInvalidResultingObjectType = 3;
const NSInteger HYDErrorMultipleErrors = 4;
const NSInteger HYDErrorGetViaAccessorFailed = 5;
const NSInteger HYDErrorSetViaAccessorFailed = 6;


NSString *HYDIsFatalKey = @"HYDIsFatal";
NSString *HYDUnderlyingErrorsKey = @"HYDUnderlyingErrors";
NSString *HYDSourceObjectKey = @"HYDSourceObject";
NSString *HYDSourceAccessorKey = @"HYDSourceAccessor";
NSString *HYDDestinationObjectKey = @"HYDDestinationObjectPath";
NSString *HYDDestinationAccessorKey = @"HYDDestinationAccessor";
