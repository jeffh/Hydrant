#import "JKSBase.h"

JKS_EXTERN NSString * JKSErrorDomain;
JKS_EXTERN const NSInteger JKSErrorInvalidSourceObjectValue;
JKS_EXTERN const NSInteger JKSErrorInvalidSourceObjectType;
JKS_EXTERN const NSInteger JKSErrorInvalidSourceObjectField;
JKS_EXTERN const NSInteger JKSErrorInvalidResultingObjectType;


@protocol JKSMapper;

@interface JKSError : NSError

+ (instancetype)mappingErrorWithCode:(NSInteger)code sourceObject:(id)sourceObject byMapper:(id<JKSMapper>)mapper;

@end
