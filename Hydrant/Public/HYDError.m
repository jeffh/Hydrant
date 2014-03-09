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
    NSString *underlyingErrors = @"";
    if (self.isFatal && self.underlyingErrors.count) {
        underlyingErrors = [self errorDescriptionFromNonHydrantErrors:[self underlyingNonHydrantErrors] hydrantErrors:[self rootFatalHydrantErrors]];
    }

    return [NSString stringWithFormat:@"%@ %@ (code=%@) because \"%@\"\n%@",
            fatalness, self.domain, [self codeAsString], self.localizedDescription,
            underlyingErrors];
}

- (NSString *)fullDescription
{
    NSString *fatalness = (self.isFatal ? @"[FATAL]" : @"[non-fatal]");
    NSString *underlyingErrors = @"";
    if (self.underlyingErrors.count) {
        underlyingErrors = [self errorDescriptionFromNonHydrantErrors:[self underlyingNonHydrantErrors] hydrantErrors:[self rootHydrantErrors]];
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
    return [self underlyingErrorsPassingBlock:^BOOL(NSError *error) {
        return ![error isKindOfClass:[HYDError class]] || [(HYDError *)error isFatal];
    }];
}

#pragma mark - Private

- (NSString *)errorDescriptionFromNonHydrantErrors:(NSArray *)nonHydrantErrors hydrantErrors:(NSArray *)hydrantErrors
{
    NSMutableString *underlyingErrors = [NSMutableString string];

    for (NSError *error in nonHydrantErrors) {
        NSString *errorString = [NSString stringWithFormat:@"[%@] (code=%ld) %@",
                                 error.domain, (long)error.code, error.localizedDescription];
        [underlyingErrors appendFormat:@"  - %@\n", HYDPrefixSubsequentLines(@"    ", errorString)];
    }

    for (HYDError *error in hydrantErrors) {
        NSString *hydrantErrorString = [NSString stringWithFormat:@"%@ (%@)", error.localizedDescription, [error codeAsString]];
        [underlyingErrors appendFormat:@"  - %@\n", HYDPrefixSubsequentLines(@"    ", hydrantErrorString)];

        for (NSError *otherError in [error underlyingNonHydrantErrors]) {
            NSString *errorString = [NSString stringWithFormat:@"[%@] (code=%ld) %@",
                                     otherError.domain, (long)otherError.code, otherError.localizedDescription];
            [underlyingErrors appendFormat:@"    |- %@\n", HYDPrefixSubsequentLines(@"       ", errorString)];
        }
    }
    return underlyingErrors;
}

- (NSArray *)underlyingErrorsPassingBlock:(BOOL(^)(NSError *error))filterBlock
{
    NSMutableArray *filteredErrors = [NSMutableArray array];
    for (NSError *error in self.underlyingErrors) {
        if (filterBlock(error)) {
            [filteredErrors addObject:error];
        }
    }
    return filteredErrors;
}

- (NSArray *)flattenedErrorsFromBlock:(NSArray *(^)(HYDError *error))getErrorsBlock
{
    NSMutableArray *errors = [NSMutableArray array];
    for (NSError *error in getErrorsBlock(self)) {
        if ([error isKindOfClass:[self class]]) {
            HYDError *innerError = (HYDError *)error;
            NSArray *underlyingErrors = [innerError flattenedErrorsFromBlock:getErrorsBlock];
            if (underlyingErrors.count) {
                [errors addObjectsFromArray:underlyingErrors];
            } else {
                [errors addObject:[HYDError errorFromError:innerError
                                       prependingSourceAccessor:self.sourceAccessor
                                         andDestinationAccessor:self.destinationAccessor
                                        replacementSourceObject:nil
                                                        isFatal:[innerError isFatal]]];
            }
        }
    }
    return errors;
}

- (NSArray *)underlyingHydrantErrors
{
    return [self underlyingErrorsPassingBlock:^BOOL(NSError *error) {
        return [error isKindOfClass:[HYDError class]];
    }];
}

- (NSArray *)underlyingNonHydrantErrors
{
    return [self underlyingErrorsPassingBlock:^BOOL(NSError *error) {
        return ![error isKindOfClass:[HYDError class]];
    }];
}

- (NSArray *)rootHydrantErrors
{
    return [self flattenedErrorsFromBlock:^NSArray *(HYDError *error) {
        return error.underlyingHydrantErrors;
    }];
}

- (NSArray *)rootFatalHydrantErrors
{
    return [self flattenedErrorsFromBlock:^NSArray *(HYDError *error) {
        return error.underlyingFatalErrors;
    }];
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
