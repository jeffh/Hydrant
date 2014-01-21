#import "JKSError+Spec.h"

@implementation JKSError (Spec)

+ (instancetype)fatalError
{
    return [self errorWithCode:JKSErrorInvalidSourceObjectType
                  sourceObject:@"sourceObject"
                     sourceKey:@"sourceKey"
             destinationObject:nil
                destinationKey:@"destinationKey"
                       isFatal:YES
              underlyingErrors:nil];
}

+ (instancetype)nonFatalError
{
    return [self errorWithCode:JKSErrorInvalidSourceObjectValue
                  sourceObject:@"sourceObject"
                     sourceKey:@"sourceKey"
             destinationObject:nil
                destinationKey:@"destinationKey"
                       isFatal:NO
              underlyingErrors:nil];
}

@end
