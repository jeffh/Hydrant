#import "JKSError+Spec.h"

@implementation JKSError (Spec)

+ (instancetype)fatalError
{
    return [self errorWithCode:JKSErrorInvalidSourceObjectType
                  sourceObject:@"sourceObject"
                     sourceKey:@"sourceKey"
                destinationKey:@"destinationKey"
                       isFatal:YES
              underlyingErrors:nil];
}

+ (instancetype)nonFatalError
{
    return [self errorWithCode:JKSErrorOptionalMappingFailed
                  sourceObject:@"sourceObject"
                     sourceKey:@"sourceKey"
                destinationKey:@"destinationKey"
                       isFatal:NO
              underlyingErrors:nil];
}

@end
