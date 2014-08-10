#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDConstants.h"
#import "HYDAccessor.h"


@interface HYDError ()

@property (assign, nonatomic, getter = isFatal) BOOL fatal;
@property (strong, nonatomic) id sourceObject;
@property (strong, nonatomic) id destinationObject;
@property (strong, nonatomic) id<HYDAccessor> sourceAccessor;
@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic) NSArray *underlyingErrors;
@property (strong, nonatomic) NSArray *underlyingFatalErrors;
@property (strong, nonatomic) NSString *localizedDescription;

@end


@implementation HYDError {
    NSDictionary *_userInfo;
}

@synthesize localizedDescription = _localizedDescription;

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    HYDError *error = [super errorWithDomain:domain code:code userInfo:dict];
    error.sourceObject = dict[HYDSourceObjectKey];
    error.sourceAccessor = dict[HYDSourceAccessorKey];
    error.destinationObject = dict[HYDDestinationObjectKey];
    error.destinationAccessor = dict[HYDDestinationAccessorKey];
    error.fatal = [dict[HYDIsFatalKey] boolValue];
    error.underlyingErrors = dict[HYDUnderlyingErrorsKey];
    error->_userInfo = dict;
    return error;
}

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
               sourceAccessor:(id<HYDAccessor>)sourceAccessor
            destinationObject:(id)destinationObject
          destinationAccessor:(id<HYDAccessor>)destinationAccessor
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors
{
    HYDError *error = [super errorWithDomain:HYDErrorDomain code:code userInfo:nil];
    error.sourceObject = sourceObject;
    error.sourceAccessor = sourceAccessor;
    error.destinationObject = destinationObject;
    error.destinationAccessor = destinationAccessor;
    error.fatal = isFatal;
    error.underlyingErrors = underlyingErrors;
    return error;
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
              underlyingErrors:error.underlyingErrors];
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

- (NSDictionary *)userInfo
{
    if (!_userInfo) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        
        userInfo[HYDIsFatalKey] = @(self.isFatal);
        
        NSArray *underlyingErrors = [NSArray arrayWithArray:self.underlyingErrors];
        if (underlyingErrors.count) {
            userInfo[NSUnderlyingErrorKey] = underlyingErrors[0];
            userInfo[HYDUnderlyingErrorsKey] = underlyingErrors;
        }
        
        HYDSetValueForKeyIfNotNil(userInfo, HYDSourceObjectKey, self.sourceObject);
        HYDSetValueForKeyIfNotNil(userInfo, HYDDestinationObjectKey, self.destinationObject);
        HYDSetValueForKeyIfNotNil(userInfo, HYDSourceAccessorKey, self.sourceAccessor);
        HYDSetValueForKeyIfNotNil(userInfo, HYDDestinationAccessorKey, self.destinationAccessor);
        HYDSetValueForKeyIfNotNil(userInfo, NSLocalizedDescriptionKey, self.localizedDescription);
        _userInfo = [userInfo copy];
    }
    return _userInfo;
}

- (NSString *)localizedDescription
{
    if (!_localizedDescription) {
        switch (self.code) {
            case HYDErrorMultipleErrors:
                _localizedDescription = HYDLocalizedStringFormat(@"Multiple parsing errors occurred (fatal=%lu, total=%lu)",
                                                                 (unsigned long)self.underlyingFatalErrors.count,
                                                                 (unsigned long)self.underlyingErrors.count);
                break;
            case HYDErrorInvalidSourceObjectValue:
            case HYDErrorInvalidSourceObjectType:
                _localizedDescription = HYDLocalizedStringFormat(@"Could not map from '%@' to '%@': got a type of %@",
                                                                 HYDStringifyAccessor(self.sourceAccessor),
                                                                 HYDStringifyAccessor(self.destinationAccessor),
                                                                 NSStringFromClass([self.sourceObject class]));
                break;
            case HYDErrorInvalidResultingObjectType:
                _localizedDescription = HYDLocalizedStringFormat(@"Could not map from '%@' to '%@': mapper produced a type of %@ from a source type of %@",
                                                                 HYDStringifyAccessor(self.sourceAccessor),
                                                                 HYDStringifyAccessor(self.destinationAccessor),
                                                                 NSStringFromClass([self.destinationObject class]),
                                                                 NSStringFromClass([self.sourceObject class]));
                break;

            case HYDErrorGetViaAccessorFailed:
                _localizedDescription = HYDLocalizedStringFormat(@"Could not map from '%@' to '%@': failed to read %@ from source object",
                                                                 HYDStringifyAccessor(self.sourceAccessor),
                                                                 HYDStringifyAccessor(self.destinationAccessor),
                                                                 [self.sourceAccessor fieldNames]);
                break;

            case HYDErrorSetViaAccessorFailed:
                _localizedDescription = HYDLocalizedStringFormat(@"Could not map from '%@' to '%@': failed to write %@ from destination object",
                                                                 HYDStringifyAccessor(self.sourceAccessor),
                                                                 HYDStringifyAccessor(self.destinationAccessor),
                                                                 [self.destinationAccessor fieldNames]);
                break;

            default: {
                _localizedDescription = HYDLocalizedStringFormat(@"Could not map from '%@' to '%@'",
                                                                 HYDStringifyAccessor(self.sourceAccessor),
                                                                 HYDStringifyAccessor(self.destinationAccessor));
                break;
            }
        }
    }
    return _localizedDescription;
}

- (NSArray *)underlyingFatalErrors
{
    if (!_underlyingFatalErrors) {
        _underlyingFatalErrors = [self underlyingErrorsPassingBlock:^BOOL(NSError *error) {
            return ![error isKindOfClass:[HYDError class]] || [(HYDError *)error isFatal];
        }];
    }
    return _underlyingFatalErrors;
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
