#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDConstants.h"

@implementation HYDError

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
               sourceAccessor:(id<HYDAccessor>)sourceAccessor
            destinationObject:(id)destinationObject
          destinationAccessor:(id<HYDAccessor>)destinationAccessor
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
    HYDSetValueForKeyIfNotNil(userInfo, HYDSourceAccessorKey, sourceAccessor);
    HYDSetValueForKeyIfNotNil(userInfo, HYDDestinationAccessorKey, destinationAccessor);

    if (code == HYDErrorMultipleErrors) {
        NSArray *fatalUnderlyingErrors = [underlyingErrors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isFatal = YES"]];
        userInfo[NSLocalizedDescriptionKey] = HYDLocalizedStringFormat(@"Multiple parsing errors occurred (fatal=%lu, total=%lu)",
                                                                       (unsigned long)fatalUnderlyingErrors.count,
                                                                       (unsigned long)underlyingErrors.count);
    } else if (!sourceAccessor && !destinationAccessor) {
        userInfo[NSLocalizedDescriptionKey] = HYDLocalizedStringFormat(@"Could not map objects");
    } else {
        userInfo[NSLocalizedDescriptionKey] = HYDLocalizedStringFormat(@"Could not map from '%@' to '%@'",
                                                                       HYDStringifyAccessor(sourceAccessor),
                                                                       HYDStringifyAccessor(destinationAccessor));
    }
    return [super errorWithDomain:HYDErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)errorFromError:(HYDError *)error
      prependingSourceAccessor:(id<HYDAccessor>)sourceAccessor
        andDestinationAccessor:(id<HYDAccessor>)destinationAccessor
       replacementSourceObject:(id)sourceObject
                       isFatal:(BOOL)isFatal
{
    sourceAccessor = HYDJoinedStringFromKeyPaths(sourceAccessor, error.sourceAccessor);
    destinationAccessor = HYDJoinedStringFromKeyPaths(destinationAccessor, error.destinationAccessor);

    sourceObject = (sourceObject ?: error.sourceObject);
    return [self errorWithCode:error.code
                  sourceObject:sourceObject
                sourceAccessor:sourceAccessor
             destinationObject:error.destinationObject
           destinationAccessor:destinationAccessor
                       isFatal:isFatal
              underlyingErrors:error.userInfo[HYDUnderlyingErrorsKey]];
}

+ (instancetype)errorFromErrors:(NSArray *)errors
                   sourceObject:(id)sourceObject
                 sourceAccessor:(id<HYDAccessor>)sourceAccessor
              destinationObject:(id)destinationObject
            destinationAccessor:(id<HYDAccessor>)destinationAccessor
                        isFatal:(BOOL)isFatal
{
    return [self errorWithCode:HYDErrorMultipleErrors
                  sourceObject:sourceObject
                sourceAccessor:sourceAccessor
             destinationObject:destinationObject
           destinationAccessor:destinationAccessor
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

- (NSString *)sourceAccessor
{
    return self.userInfo[HYDSourceAccessorKey];
}

- (NSString *)destinationAccessor
{
    return self.userInfo[HYDDestinationAccessorKey];
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
    NSMutableArray *fatalErrors = [NSMutableArray array];
    for (NSError *error in self.underlyingErrors) {
        if (![error isKindOfClass:[HYDError class]] || [(HYDError *)error isFatal]) {
            [fatalErrors addObject:error];
        }
    }
    return fatalErrors;
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
