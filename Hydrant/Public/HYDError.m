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
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    userInfo[HYDIsFatalKey] = @(isFatal);

    underlyingErrors = [NSArray arrayWithArray:underlyingErrors];
    if (underlyingErrors.count) {
        userInfo[NSUnderlyingErrorKey] = underlyingErrors[0];
        userInfo[HYDUnderlyingErrorsKey] = underlyingErrors;
    }

    HYDSetValueForKeyIfNotNil(userInfo, HYDSourceObjectKey, sourceObject);
    HYDSetValueForKeyIfNotNil(userInfo, HYDDestinationObjectKey, destinationObject);
    HYDSetValueForKeyIfNotNil(userInfo, HYDSourceKeyPathKey, sourceKey);
    HYDSetValueForKeyIfNotNil(userInfo, HYDDestinationKeyPathKey, destinationKey);

    if (code == HYDErrorMultipleErrors) {
        NSArray *fatalUnderlyingErrors = [underlyingErrors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isFatal = YES"]];
        userInfo[NSLocalizedDescriptionKey] = HYDLocalizedStringFormat(@"Multiple parsing errors occurred (fatal=%lu, total=%lu)",
                                                                       (unsigned long)fatalUnderlyingErrors.count,
                                                                       (unsigned long)underlyingErrors.count);
    } else if (!sourceKey && !destinationKey) {
        userInfo[NSLocalizedDescriptionKey] = HYDLocalizedStringFormat(@"Could not map objects");
    } else {
        userInfo[NSLocalizedDescriptionKey] = HYDLocalizedStringFormat(@"Could not map from '%@' to '%@'",
                                                                       sourceKey ?: @"<UnknownKey>",
                                                                       destinationKey ?: @"<UnknownKey>");
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
             destinationObject:error.destinationObject
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
    NSString *fatalness = (self.isFatal ? @"YES" : @"NO");
    NSMutableString *underlyingErrors = [NSMutableString string];
    if (self.underlyingErrors.count) {
        [underlyingErrors appendString:@" underlyingErrors=(\n"];
        for (NSError *error in self.underlyingErrors) {
            [underlyingErrors appendFormat:@"  - %@\n", HYDPrefixSubsequentLines(@"    ", error.description)];
        }
        [underlyingErrors appendString:@")"];
    }

    return [NSString stringWithFormat:@"%@ code=%lu isFatal=%@ reason=\"%@\"%@",
            self.domain, (long)self.code, fatalness, self.localizedDescription, underlyingErrors];
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

- (NSArray *)underlyingFatalErrors
{
    return [self.underlyingErrors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isFatal = YES"]];
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
