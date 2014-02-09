#import "HYDError+Spec.h"
#import "HYDAccessor.h"
#import "HYDKeyAccessor.h"

@implementation HYDError (Spec)

+ (instancetype)fatalError
{
    return [self errorWithCode:HYDErrorInvalidSourceObjectType
                  sourceObject:@"sourceObject"
                sourceAccessor:HYDAccessKey(@"sourceAccessor")
             destinationObject:nil
           destinationAccessor:HYDAccessKey(@"destinationAccessor")
                       isFatal:YES
              underlyingErrors:nil];
}

+ (instancetype)nonFatalError
{
    return [self errorWithCode:HYDErrorInvalidSourceObjectValue
                  sourceObject:@"sourceObject"
                sourceAccessor:HYDAccessKey(@"sourceAccessor")
             destinationObject:nil
           destinationAccessor:HYDAccessKey(@"destinationAccessor")
                       isFatal:NO
              underlyingErrors:nil];
}

@end
