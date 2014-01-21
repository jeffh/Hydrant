#import "JKSError.h"
#import "JKSMapper.h"
#import "JKSFunctions.h"

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
    NSMutableDictionary *userInfo = [@{JKSSourceObjectKey: (sourceObject ?: [NSNull null]),
                                       JKSDestinationObjectKey: (destinationObject ?: [NSNull null]),
                                       JKSIsFatalKey: @(isFatal)} mutableCopy];
    underlyingErrors = [NSArray arrayWithArray:underlyingErrors];
    if (underlyingErrors.count) {
        userInfo[NSUnderlyingErrorKey] = underlyingErrors[0];
        userInfo[JKSUnderlyingErrorsKey] = underlyingErrors;
    }

    JKSSetValueForKeyIfNotNil(userInfo, JKSSourceKeyPathKey, sourceKey);
    JKSSetValueForKeyIfNotNil(userInfo, JKSDestinationKeyPathKey, destinationKey);

    if (underlyingErrors.count) {
        NSMutableString *details = [NSMutableString stringWithFormat:@"Multiple errors occurred:\n"];
        for (JKSError *error in underlyingErrors) {
            [details appendFormat:@" - %@", [error underlyingErrorsDescription]];
        }
        userInfo[NSLocalizedDescriptionKey] = details;
    } else {
        userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"Could not map from '%@' to '%@'", sourceKey, destinationKey];
    }
    return [self errorWithDomain:JKSErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)errorFromError:(JKSError *)error
           prependingSourceKey:(NSString *)sourceKey
             andDestinationKey:(NSString *)destinationKey
       replacementSourceObject:(id)sourceObject
                       isFatal:(BOOL)isFatal
{
    sourceKey = JKSJoinedStringFromKeyPaths(sourceKey, error.sourceKey);
    destinationKey = JKSJoinedStringFromKeyPaths(destinationKey, error.destinationKey);

    sourceObject = (sourceObject ?: error.sourceObject);
    return [self errorWithCode:error.code
                  sourceObject:sourceObject
                     sourceKey:sourceKey
             destinationObject:nil
                destinationKey:destinationKey
                       isFatal:isFatal
              underlyingErrors:error.userInfo[JKSUnderlyingErrorsKey]];
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

- (NSString *)description
{
    return [[[super description]
             stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]
            stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
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

- (id)destinationObject
{
    return self.userInfo[JKSDestinationObjectKey];
}

- (NSString *)underlyingErrorsDescription
{
    NSArray *underlyingErrors = self.userInfo[JKSUnderlyingErrorsKey];
    if (underlyingErrors.count) {
        NSMutableString *string = [NSMutableString string];
        for (JKSError *error in underlyingErrors) {
            [string appendFormat:@"%@\n", [error underlyingErrorsDescription]];
        }
        return string;
    } else {
        return [self localizedDescription];
    }
}

@end
