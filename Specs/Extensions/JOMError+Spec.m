#import "JOMError+Spec.h"

@implementation JOMError (Spec)

+ (instancetype)fatalError
{
    return [self errorWithCode:JOMErrorInvalidSourceObjectType
                  sourceObject:@"sourceObject"
                     sourceKey:@"sourceKey"
             destinationObject:nil
                destinationKey:@"destinationKey"
                       isFatal:YES
              underlyingErrors:nil];
}

+ (instancetype)nonFatalError
{
    return [self errorWithCode:JOMErrorInvalidSourceObjectValue
                  sourceObject:@"sourceObject"
                     sourceKey:@"sourceKey"
             destinationObject:nil
                destinationKey:@"destinationKey"
                       isFatal:NO
              underlyingErrors:nil];
}

@end
