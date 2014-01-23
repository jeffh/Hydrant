#import "HYDError+Spec.h"

@implementation HYDError (Spec)

+ (instancetype)fatalError
{
    return [self errorWithCode:HYDErrorInvalidSourceObjectType
                  sourceObject:@"sourceObject"
                     sourceKey:@"sourceKey"
             destinationObject:nil
                destinationKey:@"destinationKey"
                       isFatal:YES
              underlyingErrors:nil];
}

+ (instancetype)nonFatalError
{
    return [self errorWithCode:HYDErrorInvalidSourceObjectValue
                  sourceObject:@"sourceObject"
                     sourceKey:@"sourceKey"
             destinationObject:nil
                destinationKey:@"destinationKey"
                       isFatal:NO
              underlyingErrors:nil];
}

@end
