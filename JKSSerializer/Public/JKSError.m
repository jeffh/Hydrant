#import "JKSError.h"
#import "JKSMapper.h"

NSString * JKSErrorDomain = @"JKSErrorDomain";
const NSInteger JKSErrorInvalidSourceObjectValue = 1;
const NSInteger JKSErrorInvalidSourceObjectType = 2;
const NSInteger JKSErrorInvalidSourceObjectField = 3;
const NSInteger JKSErrorInvalidResultingObjectType = 4;

@implementation JKSError

+ (instancetype)mappingErrorWithCode:(NSInteger)code sourceObject:(id)sourceObject byMapper:(id<JKSMapper>)mapper
{
    return [self errorWithDomain:JKSErrorDomain
                            code:code
                        userInfo:@{@"sourceObject": (sourceObject ?: [NSNull null]),
                                   @"mapper": mapper,
                                   @"destinationKey": [mapper destinationKey]}];
}

@end
