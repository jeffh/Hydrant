#import "HYDError.h"
#import "HYDMapper.h"
#import "HYDFunctions.h"

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


@implementation HYDError

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
                    sourceKey:(NSString *)sourceKey
            destinationObject:(id)destinationObject
               destinationKey:(NSString *)destinationKey
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors
{
    NSMutableDictionary *userInfo = [@{HYDSourceObjectKey : (sourceObject ?: [NSNull null]),
            HYDDestinationObjectKey : (destinationObject ?: [NSNull null]),
            HYDIsFatalKey : @(isFatal)} mutableCopy];
    underlyingErrors = [NSArray arrayWithArray:underlyingErrors];
    if (underlyingErrors.count) {
        userInfo[NSUnderlyingErrorKey] = underlyingErrors[0];
        userInfo[HYDUnderlyingErrorsKey] = underlyingErrors;
    }

    HYDSetValueForKeyIfNotNil(userInfo, HYDSourceKeyPathKey, sourceKey);
    HYDSetValueForKeyIfNotNil(userInfo, HYDDestinationKeyPathKey, destinationKey);

    if (underlyingErrors.count) {
        NSMutableString *details = [HYDLocalizedStringFormat(@"Multiple errors occurred:\n") mutableCopy];
        for (NSError *error in underlyingErrors) {
            if ([error respondsToSelector:@selector(underlyingErrorsDescription)]) {
                [details appendFormat:@" - %@", [(HYDError *)error underlyingErrorsDescription]];
            } else {
                [details appendFormat:@" - %@", [error description]];
            }
        }
        userInfo[NSLocalizedDescriptionKey] = details;
    } else {
        userInfo[NSLocalizedDescriptionKey] = HYDLocalizedStringFormat(@"Could not map from '%@' to '%@'", sourceKey, destinationKey);
    }
    return [self errorWithDomain:HYDErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)errorFromError:(HYDError *)error
           prependingSourceKey:(NSString *)sourceKey
             andDestinationKey:(NSString *)destinationKey
       replacementSourceObject:(id)sourceObject
                       isFatal:(BOOL)isFatal
{
    sourceKey = HYDJoinedStringFromKeyPaths(sourceKey, error.sourceKey);
    destinationKey = HYDJoinedStringFromKeyPaths(destinationKey, error.destinationKey);

    sourceObject = (sourceObject ?: error.sourceObject);
    return [self errorWithCode:error.code
                  sourceObject:sourceObject
                     sourceKey:sourceKey
             destinationObject:nil
                destinationKey:destinationKey
                       isFatal:isFatal
              underlyingErrors:error.userInfo[HYDUnderlyingErrorsKey]];
}

+ (instancetype)errorFromErrors:(NSArray *)errors
                   sourceObject:(id)sourceObject
                      sourceKey:(NSString *)sourceKey
              destinationObject:(id)destinationObject
                 destinationKey:(NSString *)destinationKey
                        isFatal:(BOOL)isFatal
{
    return [self errorWithCode:HYDErrorMultipleErrors
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
    return [self.userInfo[HYDIsFatalKey] boolValue];
}

- (NSString *)sourceKey
{
    return self.userInfo[HYDSourceKeyPathKey];
}

- (NSString *)destinationKey
{
    return self.userInfo[HYDDestinationKeyPathKey];
}

- (id)sourceObject
{
    return self.userInfo[HYDSourceObjectKey];
}

- (id)destinationObject
{
    return self.userInfo[HYDDestinationObjectKey];
}

- (NSArray *)underlyingErrors
{
    return self.userInfo[HYDUnderlyingErrorsKey];
}

- (NSString *)underlyingErrorsDescription
{
    NSArray *underlyingErrors = self.userInfo[HYDUnderlyingErrorsKey];
    if (underlyingErrors.count) {
        NSMutableString *string = [NSMutableString string];
        for (NSError *error in underlyingErrors) {
            if ([error respondsToSelector:@selector(underlyingErrorsDescription)]) {
                [string appendFormat:@"%@\n", [(HYDError *)error underlyingErrorsDescription]];
            } else {
                [string appendFormat:@"%@\n", [error description]];
            }
        }
        return string;
    } else {
        return [self localizedDescription];
    }
}

@end
