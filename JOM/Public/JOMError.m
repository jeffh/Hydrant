#import "JOMError.h"
#import "JOMMapper.h"
#import "JOMFunctions.h"

NSString *JOMErrorDomain = @"JOMErrorDomain";
const NSInteger JOMErrorInvalidSourceObjectValue = 1;
const NSInteger JOMErrorInvalidSourceObjectType = 2;
const NSInteger JOMErrorInvalidResultingObjectType = 3;
const NSInteger JOMErrorMultipleErrors = 4;


NSString *JOMIsFatalKey = @"JOMIsFatal";
NSString *JOMUnderlyingErrorsKey = @"JOMUnderlyingErrors";
NSString *JOMSourceObjectKey = @"JOMSourceObject";
NSString *JOMSourceKeyPathKey = @"JOMSourceKeyPath";
NSString *JOMDestinationObjectKey = @"JOMDestinationObjectPath";
NSString *JOMDestinationKeyPathKey = @"JOMDestinationKeyPath";


@implementation JOMError

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
                    sourceKey:(NSString *)sourceKey
            destinationObject:(id)destinationObject
               destinationKey:(NSString *)destinationKey
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors
{
    NSMutableDictionary *userInfo = [@{JOMSourceObjectKey : (sourceObject ?: [NSNull null]),
            JOMDestinationObjectKey : (destinationObject ?: [NSNull null]),
            JOMIsFatalKey : @(isFatal)} mutableCopy];
    underlyingErrors = [NSArray arrayWithArray:underlyingErrors];
    if (underlyingErrors.count) {
        userInfo[NSUnderlyingErrorKey] = underlyingErrors[0];
        userInfo[JOMUnderlyingErrorsKey] = underlyingErrors;
    }

    JOMSetValueForKeyIfNotNil(userInfo, JOMSourceKeyPathKey, sourceKey);
    JOMSetValueForKeyIfNotNil(userInfo, JOMDestinationKeyPathKey, destinationKey);

    if (underlyingErrors.count) {
        NSMutableString *details = [NSMutableString stringWithFormat:@"Multiple errors occurred:\n"];
        for (JOMError *error in underlyingErrors) {
            [details appendFormat:@" - %@", [error underlyingErrorsDescription]];
        }
        userInfo[NSLocalizedDescriptionKey] = details;
    } else {
        userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"Could not map from '%@' to '%@'", sourceKey, destinationKey];
    }
    return [self errorWithDomain:JOMErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)errorFromError:(JOMError *)error
           prependingSourceKey:(NSString *)sourceKey
             andDestinationKey:(NSString *)destinationKey
       replacementSourceObject:(id)sourceObject
                       isFatal:(BOOL)isFatal
{
    sourceKey = JOMJoinedStringFromKeyPaths(sourceKey, error.sourceKey);
    destinationKey = JOMJoinedStringFromKeyPaths(destinationKey, error.destinationKey);

    sourceObject = (sourceObject ?: error.sourceObject);
    return [self errorWithCode:error.code
                  sourceObject:sourceObject
                     sourceKey:sourceKey
             destinationObject:nil
                destinationKey:destinationKey
                       isFatal:isFatal
              underlyingErrors:error.userInfo[JOMUnderlyingErrorsKey]];
}

+ (instancetype)errorFromErrors:(NSArray *)errors
                   sourceObject:(id)sourceObject
                      sourceKey:(NSString *)sourceKey
              destinationObject:(id)destinationObject
                 destinationKey:(NSString *)destinationKey
                        isFatal:(BOOL)isFatal
{
    return [self errorWithCode:JOMErrorMultipleErrors
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
    return [self.userInfo[JOMIsFatalKey] boolValue];
}

- (NSString *)sourceKey
{
    return self.userInfo[JOMSourceKeyPathKey];
}

- (NSString *)destinationKey
{
    return self.userInfo[JOMDestinationKeyPathKey];
}

- (id)sourceObject
{
    return self.userInfo[JOMSourceObjectKey];
}

- (id)destinationObject
{
    return self.userInfo[JOMDestinationObjectKey];
}

- (NSString *)underlyingErrorsDescription
{
    NSArray *underlyingErrors = self.userInfo[JOMUnderlyingErrorsKey];
    if (underlyingErrors.count) {
        NSMutableString *string = [NSMutableString string];
        for (JOMError *error in underlyingErrors) {
            [string appendFormat:@"%@\n", [error underlyingErrorsDescription]];
        }
        return string;
    } else {
        return [self localizedDescription];
    }
}

@end
