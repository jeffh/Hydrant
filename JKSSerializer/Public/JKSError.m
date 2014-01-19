#import "JKSError.h"
#import "JKSMapper.h"

NSString * JKSErrorDomain = @"JKSErrorDomain";
const NSInteger JKSErrorInvalidSourceObjectValue = 1;
const NSInteger JKSErrorInvalidSourceObjectType = 2;
const NSInteger JKSErrorInvalidSourceObjectField = 3;
const NSInteger JKSErrorInvalidResultingObjectType = 4;
const NSInteger JKSErrorOptionalMappingFailed = 100;

@implementation JKSError

+ (instancetype)mappingErrorWithCode:(NSInteger)code sourceObject:(id)sourceObject byMapper:(id<JKSMapper>)mapper
{
    return [self errorWithDomain:JKSErrorDomain
                            code:code
                        userInfo:@{@"sourceObject": (sourceObject ?: [NSNull null]),
                                   @"mapper": NSStringFromClass([mapper class]),
                                   @"isFatal": @(code != JKSErrorOptionalMappingFailed),
                                   @"destinationKey": [mapper destinationKey] ?: [NSNull null]}];
}

+ (instancetype)wrapErrors:(NSArray *)errors intoCode:(NSInteger)code sourceObject:(id)sourceObject byMapper:(id<JKSMapper>)mapper
{
    return [self errorWithDomain:JKSErrorDomain
                            code:code
                        userInfo:@{@"errors": errors,
                                   @"isFatal": @(code != JKSErrorOptionalMappingFailed),
                                   @"sourceObject": sourceObject ?: [NSNull null]}];
}

+ (instancetype)wrapError:(JKSError *)error intoCode:(NSInteger)code byMapper:(id<JKSMapper>)mapper
{
    return [self errorWithDomain:JKSErrorDomain
                            code:code
                        userInfo:@{@"originalError": error,
                                   @"isFatal": @(code != JKSErrorOptionalMappingFailed),
                                   @"wrappingMapper": NSStringFromClass([mapper class])}];
}

- (BOOL)isFatal
{
    return [self.userInfo[@"isFatal"] boolValue];
}

@end
