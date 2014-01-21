#import "JKSError.h"
#import "JKSMapper.h"

NSString * JKSErrorDomain = @"JKSErrorDomain";
const NSInteger JKSErrorInvalidSourceObjectValue = 1;
const NSInteger JKSErrorInvalidSourceObjectType = 2;
const NSInteger JKSErrorInvalidResultingObjectType = 3;
const NSInteger JKSErrorOptionalMappingFailed = 4;
const NSInteger JKSErrorMultipleErrors = 5;
const NSInteger JKSErrorMultipleOptionalErrors = 6;


NSString * JKSIsFatalKey = @"JKSIsFatal";
NSString * JKSIsDecoratorKey = @"JKSIsDecorator";
NSString * JKSUnderlyingErrorsKey = @"JKSUnderlyingErrors";
NSString * JKSSourceObjectKey = @"JKSSourceObject";
NSString * JKSSourceKeyPathKey = @"JKSSourceKeyPath";
NSString * JKSDestinationKeyPathKey = @"JKSDestinationKeyPath";
NSString * JKSMapperClassKey = @"JKSMapperClass";


@implementation JKSError

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
                    sourceKey:(NSString *)sourceKey
               destinationKey:(NSString *)destinationKey
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors
{
    underlyingErrors = [NSArray arrayWithArray:underlyingErrors];
    NSMutableDictionary *userInfo = [@{JKSSourceObjectKey: (sourceObject ?: [NSNull null]),
            JKSIsFatalKey: @(isFatal),
            JKSIsDecoratorKey: @(destinationKey == nil),
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

+ (instancetype)errorWithCode:(NSInteger)code sourceObject:(id)sourceObject byMapper:(id<JKSMapper>)mapper
{
    return [self errorWithDomain:JKSErrorDomain
                            code:code
                        userInfo:@{JKSSourceObjectKey: (sourceObject ?: [NSNull null]),
                                   JKSMapperClassKey: NSStringFromClass([mapper class]),
                                   JKSIsFatalKey: @(code != JKSErrorOptionalMappingFailed),
                                   JKSDestinationKeyPathKey: [mapper destinationKey] ?: [NSNull null],
                                   JKSIsDecoratorKey: @NO}];
}

+ (instancetype)wrapErrors:(NSArray *)errors
                  intoCode:(NSInteger)code
              sourceObject:(id)sourceObject
                  byMapper:(id<JKSMapper>)mapper
{
    return [self errorWithDomain:JKSErrorDomain
                            code:code
                        userInfo:@{JKSUnderlyingErrorsKey: errors,
                                   NSUnderlyingErrorKey: errors[0],
                                   JKSIsFatalKey: @(code != JKSErrorOptionalMappingFailed),
                                   JKSSourceObjectKey: (sourceObject ?: [NSNull null]),
                                   JKSIsDecoratorKey: @NO,
                                   JKSMapperClassKey: NSStringFromClass([mapper class]),
                                   JKSDestinationKeyPathKey: [mapper destinationKey] ?: [NSNull null]}];
}

+ (instancetype)wrapError:(JKSError *)error intoCode:(NSInteger)code byMapper:(id<JKSMapper>)mapper
{
    return [self errorWithDomain:JKSErrorDomain
                            code:code
                        userInfo:@{NSUnderlyingErrorKey: error,
                                   JKSUnderlyingErrorsKey: @[error],
                                   JKSIsFatalKey: @(code != JKSErrorOptionalMappingFailed),
                                   JKSMapperClassKey: NSStringFromClass([mapper class]),
                                   JKSDestinationKeyPathKey: [mapper destinationKey],
                                   JKSIsDecoratorKey: @YES}];
}

- (BOOL)isFatal
{
    return [self.userInfo[JKSIsFatalKey] boolValue];
}

- (BOOL)isDecorator
{
    return [self.userInfo[JKSIsDecoratorKey] boolValue];
}

- (NSArray *)errorKeyPaths
{
    NSMutableArray *errorKeyPaths = [NSMutableArray array];
    if ([self.userInfo[JKSUnderlyingErrorsKey] count]) {
        for (JKSError *error in self.userInfo[JKSUnderlyingErrorsKey]) {
            for (NSString *keyPath in [error errorKeyPaths]) {
                NSString *path = nil;
                if (self.isDecorator) {
                    path = keyPath;
                } else {
                    path = [NSString stringWithFormat:@"%@.%@", self.userInfo[JKSDestinationKeyPathKey], keyPath];
                }
                [errorKeyPaths addObject:path];
            }
        }
    } else {
        [errorKeyPaths addObject:self.userInfo[JKSDestinationKeyPathKey]];
    }
    return errorKeyPaths;
}

@end
