#import "JKSBase.h"

JKS_EXTERN NSString * JKSErrorDomain;
JKS_EXTERN const NSInteger JKSErrorInvalidSourceObjectValue;
JKS_EXTERN const NSInteger JKSErrorInvalidSourceObjectType;
JKS_EXTERN const NSInteger JKSErrorInvalidResultingObjectType;
JKS_EXTERN const NSInteger JKSErrorOptionalMappingFailed;
JKS_EXTERN const NSInteger JKSErrorMultipleErrors;
JKS_EXTERN const NSInteger JKSErrorMultipleOptionalErrors;

JKS_EXTERN NSString * JKSIsFatalKey;
JKS_EXTERN NSString * JKSIsDecoratorKey;
JKS_EXTERN NSString * JKSUnderlyingErrorsKey;
JKS_EXTERN NSString * JKSSourceObjectKey;
JKS_EXTERN NSString * JKSSourceKeyPathKey;
JKS_EXTERN NSString * JKSDestinationKeyPathKey;
JKS_EXTERN NSString * JKSMapperClassKey;

@protocol JKSMapper;

@interface JKSError : NSError

+ (instancetype)errorWithCode:(NSInteger)code sourceObject:(id)sourceObject sourceKey:(NSString *)sourceKey destinationKey:(NSString *)destinationKey isFatal:(BOOL)isFatal underlyingErrors:(NSArray *)underlyingErrors;

+ (instancetype)errorWithCode:(NSInteger)code sourceObject:(id)sourceObject byMapper:(id<JKSMapper>)mapper;
+ (instancetype)wrapErrors:(NSArray *)errors intoCode:(NSInteger)code sourceObject:(id)sourceObject byMapper:(id<JKSMapper>)mapper;
+ (instancetype)wrapError:(JKSError *)error intoCode:(NSInteger)code byMapper:(id<JKSMapper>)mapper;

- (BOOL)isFatal;
- (BOOL)isDecorator;
- (NSArray *)errorKeyPaths;

@end
