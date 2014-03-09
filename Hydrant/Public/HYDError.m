#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDConstants.h"

@implementation HYDError

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
        NSString *predicate = [NSString stringWithFormat:@"userInfo.%@ = YES", HYDIsFatalKey];
        NSArray *fatalUnderlyingErrors = [underlyingErrors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicate]];
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
    NSString *fatalness = (self.isFatal ? @"[FATAL]" : @"[non-fatal]");
    NSMutableString *underlyingErrors = [NSMutableString string];
    if (self.isFatal && self.underlyingErrors.count) {
        for (NSError *error in self.nonHydrantErrors) {
            NSString *errorString = [NSString stringWithFormat:@"[%@] (code=%ld) %@", error.domain, error.code, error.localizedDescription];
            [underlyingErrors appendFormat:@"  - %@\n", HYDPrefixSubsequentLines(@"    ", errorString)];
        }

        for (HYDError *error in self.rootFatalHydrantErrors) {
            NSString *hydrantErrorString = [NSString stringWithFormat:@"%@ (%@)", error.localizedDescription, [error codeAsString]];
            [underlyingErrors appendFormat:@"  - %@\n", HYDPrefixSubsequentLines(@"    ", hydrantErrorString)];

            NSArray *nonHydrantErrors = [error nonHydrantErrors];
            for (NSError *otherError in nonHydrantErrors) {
                NSString *errorString = [NSString stringWithFormat:@"[%@] (code=%ld) %@",
                                         otherError.domain, otherError.code, otherError.localizedDescription];
                [underlyingErrors appendFormat:@"    |- %@\n", HYDPrefixSubsequentLines(@"    ", errorString)];
            }
        }
    }

    return [NSString stringWithFormat:@"%@ %@ (code=%@) because \"%@\"\n%@",
            fatalness, self.domain, [self codeAsString], self.localizedDescription,
            underlyingErrors];
}

- (NSString *)recursiveDescription
{
    NSString *fatalness = (self.isFatal ? @"YES" : @"NO");
    NSMutableString *underlyingErrors = [NSMutableString string];
    if (self.isFatal && self.underlyingErrors.count) {
        [underlyingErrors appendString:@" underlyingFatalErrors=(\n"];
        for (NSError *error in self.underlyingFatalErrors) {
            NSString *errorDescription = nil;
            if ([error respondsToSelector:@selector(recursiveDescription)]) {
                errorDescription = [(HYDError *)error recursiveDescription];
            } else {
                errorDescription = error.description;
            }
            [underlyingErrors appendFormat:@"  - %@\n", HYDPrefixSubsequentLines(@"    ", errorDescription)];
        }
        [underlyingErrors appendString:@")"];
    }

    return [NSString stringWithFormat:@"%@ code=%lu isFatal=%@ reason=\"%@\"%@",
            self.domain, (long)self.code, fatalness, self.localizedDescription, underlyingErrors];
}

- (NSString *)fullRecursiveDescription
{
    NSString *fatalness = (self.isFatal ? @"YES" : @"NO");
    NSMutableString *underlyingErrors = [NSMutableString string];
    if (self.underlyingErrors.count) {
        [underlyingErrors appendString:@" underlyingErrors=(\n"];
        for (NSError *error in self.underlyingErrors) {
            NSString *errorDescription = nil;
            if ([error respondsToSelector:@selector(fullRecursiveDescription)]) {
                errorDescription = [(HYDError *)error fullRecursiveDescription];
            } else {
                errorDescription = error.description;
            }
            [underlyingErrors appendFormat:@"  - %@\n", HYDPrefixSubsequentLines(@"    ", errorDescription)];
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

- (NSArray *)nonHydrantErrors
{
    NSMutableArray *otherErrors = [NSMutableArray array];
    for (NSError *error in self.underlyingErrors) {
        if (![error isKindOfClass:[HYDError class]]) {
            [otherErrors addObject:error];
        }
    }
    return otherErrors;
}

- (NSArray *)rootFatalHydrantErrors
{
    NSMutableArray *fatalErrors = [NSMutableArray array];
    for (NSError *error in self.underlyingFatalErrors) {
        if ([error isKindOfClass:[self class]]) {
            HYDError *innerError = (HYDError *)error;
            NSArray *underlyingErrors = [innerError rootFatalHydrantErrors];
            if (underlyingErrors.count) {
                [fatalErrors addObjectsFromArray:underlyingErrors];
            } else {
                [fatalErrors addObject:[HYDError errorFromError:innerError
                                       prependingSourceAccessor:self.sourceAccessor
                                         andDestinationAccessor:self.destinationAccessor
                                        replacementSourceObject:nil
                                                        isFatal:[innerError isFatal]]];
            }
        }
    }
    return fatalErrors;
}

- (NSString *)codeAsString
{
    NSDictionary *mapping = @{@(HYDErrorGetViaAccessorFailed): @"HYDErrorGetViaAccessorFailed",
                              @(HYDErrorInvalidResultingObjectType): @"HYDErrorInvalidResultingObjectType",
                              @(HYDErrorInvalidSourceObjectType): @"HYDErrorInvalidSourceObjectType",
                              @(HYDErrorInvalidSourceObjectValue): @"HYDErrorInvalidSourceObjectValue",
                              @(HYDErrorMultipleErrors): @"HYDErrorMultipleErrors",
                              @(HYDErrorSetViaAccessorFailed): @"HYDSetViaAccessorFailed"};

    return mapping[@(self.code)] ?: [NSString stringWithFormat:@"%llu", (unsigned long long)self.code];
}

@end
