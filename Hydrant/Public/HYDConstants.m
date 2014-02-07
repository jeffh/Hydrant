#import "HYDConstants.h"

NSString *HYDDateFormatRFC3339 = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
id HYDRootMapper = nil;

NSString *HYDErrorDomain = @"HYDErrorDomain";
const NSInteger HYDErrorInvalidSourceObjectValue = 1;
const NSInteger HYDErrorInvalidSourceObjectType = 2;
const NSInteger HYDErrorInvalidResultingObjectType = 3;
const NSInteger HYDErrorMultipleErrors = 4;


NSString *HYDIsFatalKey = @"HYDIsFatal";
NSString *HYDUnderlyingErrorsKey = @"HYDUnderlyingErrors";
NSString *HYDSourceObjectKey = @"HYDSourceObject";
NSString *HYDSourceKeyPathKey = @"HYDSourceKeyPath";
NSString *HYDDestinationObjectKey = @"HYDDestinationObjectPath";
NSString *HYDDestinationKeyPathKey = @"HYDDestinationKeyPath";
