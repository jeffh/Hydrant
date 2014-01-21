#import "JKSBase.h"

JKS_EXTERN NSString * JKSErrorDomain;
JKS_EXTERN const NSInteger JKSErrorInvalidSourceObjectValue;
JKS_EXTERN const NSInteger JKSErrorInvalidSourceObjectType;
JKS_EXTERN const NSInteger JKSErrorInvalidResultingObjectType;
JKS_EXTERN const NSInteger JKSErrorMultipleErrors;

JKS_EXTERN NSString * JKSIsFatalKey;
JKS_EXTERN NSString * JKSUnderlyingErrorsKey;
JKS_EXTERN NSString * JKSSourceObjectKey;
JKS_EXTERN NSString * JKSSourceKeyPathKey;
JKS_EXTERN NSString * JKSDestinationObjectKey;
JKS_EXTERN NSString * JKSDestinationKeyPathKey;

@protocol JKSMapper;

@interface JKSError : NSError

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
                    sourceKey:(NSString *)sourceKey
            destinationObject:(id)destinationObject
               destinationKey:(NSString *)destinationKey
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors;

+ (instancetype)errorFromError:(JKSError *)error
           prependingSourceKey:(NSString *)sourceKey
             andDestinationKey:(NSString *)destinationKey
       replacementSourceObject:(id)sourceObject
                       isFatal:(BOOL)isFatal;

+ (instancetype)errorFromErrors:(NSArray *)errors
                   sourceObject:(id)sourceObject
                      sourceKey:(NSString *)sourceKey
              destinationObject:(id)destinationObject
                 destinationKey:(NSString *)destinationKey
                        isFatal:(BOOL)isFatal;

- (BOOL)isFatal;
- (NSString *)sourceKey;
- (NSString *)destinationKey;
- (id)sourceObject;
- (NSArray *)errorKeyPaths;

@end
