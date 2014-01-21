#import "JKSError.h"
#import "JKSMapper.h"

NSString * JKSErrorDomain = @"JKSErrorDomain";
const NSInteger JKSErrorInvalidSourceObjectValue = 1;
const NSInteger JKSErrorInvalidSourceObjectType = 2;
const NSInteger JKSErrorInvalidResultingObjectType = 3;
const NSInteger JKSErrorMultipleErrors = 4;


NSString * JKSIsFatalKey = @"JKSIsFatal";
NSString * JKSUnderlyingErrorsKey = @"JKSUnderlyingErrors";
NSString * JKSSourceObjectKey = @"JKSSourceObject";
NSString * JKSSourceKeyPathKey = @"JKSSourceKeyPath";
NSString * JKSDestinationObjectKey = @"JKSDestinationObjectPath";
NSString * JKSDestinationKeyPathKey = @"JKSDestinationKeyPath";


@implementation JKSError

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
                    sourceKey:(NSString *)sourceKey
            destinationObject:(id)destinationObject
               destinationKey:(NSString *)destinationKey
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors
{
    underlyingErrors = [NSArray arrayWithArray:underlyingErrors];
    NSMutableDictionary *userInfo = [@{JKSSourceObjectKey: (sourceObject ?: [NSNull null]),
            JKSDestinationObjectKey: (destinationObject ?: [NSNull null]),
            JKSIsFatalKey: @(isFatal),
            JKSUnderlyingErrorsKey: underlyingErrors} mutableCopy];
    if (underlyingErrors.count) {
        userInfo[NSUnderlyingErrorKey] = underlyingErrors[0];
    }
    if (sourceKey) {
        userInfo[JKSSourceKeyPathKey] = sourceKey;
    }
    if (destinationKey) {
        userInfo[JKSDestinationKeyPathKey] = destinationKey;
    }
    return [self errorWithDomain:JKSErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)errorFromError:(JKSError *)error
           prependingSourceKey:(NSString *)sourceKey
             andDestinationKey:(NSString *)destinationKey
       replacementSourceObject:(id)sourceObject
                       isFatal:(BOOL)isFatal
{
    sourceKey = (sourceKey ? [NSString stringWithFormat:@"%@.%@", sourceKey, error.sourceKey] : error.sourceKey);
    destinationKey = (destinationKey ? [NSString stringWithFormat:@"%@.%@", destinationKey, error.destinationKey] : error.destinationKey);
    sourceObject = (sourceObject ?: error.sourceObject);
    return [self errorWithCode:error.code sourceObject:sourceObject sourceKey:sourceKey destinationObject:nil destinationKey:destinationKey isFatal:isFatal underlyingErrors:error.userInfo[JKSUnderlyingErrorsKey]];
}

+ (instancetype)errorFromErrors:(NSArray *)errors
                   sourceObject:(id)sourceObject
                      sourceKey:(NSString *)sourceKey
              destinationObject:(id)destinationObject
                 destinationKey:(NSString *)destinationKey
                        isFatal:(BOOL)isFatal
{
    return [self errorWithCode:JKSErrorMultipleErrors
                  sourceObject:sourceObject
                     sourceKey:sourceKey
             destinationObject:destinationObject
                destinationKey:destinationKey
                       isFatal:isFatal
              underlyingErrors:errors];
}

- (BOOL)isFatal
{
    return [self.userInfo[JKSIsFatalKey] boolValue];
}

- (NSString *)sourceKey
{
    return self.userInfo[JKSSourceKeyPathKey];
}

- (NSString *)destinationKey
{
    return self.userInfo[JKSDestinationKeyPathKey];
}

- (id)sourceObject
{
    return self.userInfo[JKSSourceObjectKey];
}

- (NSArray *)errorKeyPaths
{
    NSMutableArray *errorKeyPaths = [NSMutableArray array];
    if ([self.userInfo[JKSUnderlyingErrorsKey] count]) {
        for (JKSError *error in self.userInfo[JKSUnderlyingErrorsKey]) {
            for (NSString *keyPath in [error errorKeyPaths]) {
                NSString *path = [NSString stringWithFormat:@"%@.%@", self.userInfo[JKSDestinationKeyPathKey], keyPath];
                [errorKeyPaths addObject:path];
            }
        }
    } else {
        [errorKeyPaths addObject:self.userInfo[JKSDestinationKeyPathKey]];
    }
    return errorKeyPaths;
}

@end
