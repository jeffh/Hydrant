#import "HYDBase.h"

HYD_EXTERN NSString *HYDErrorDomain;
HYD_EXTERN const NSInteger HYDErrorInvalidSourceObjectValue;
HYD_EXTERN const NSInteger HYDErrorInvalidSourceObjectType;
HYD_EXTERN const NSInteger HYDErrorInvalidResultingObjectType;
HYD_EXTERN const NSInteger HYDErrorMultipleErrors;

HYD_EXTERN NSString *HYDIsFatalKey;
HYD_EXTERN NSString *HYDUnderlyingErrorsKey;
HYD_EXTERN NSString *HYDSourceObjectKey;
HYD_EXTERN NSString *HYDSourceKeyPathKey;
HYD_EXTERN NSString *HYDDestinationObjectKey;
HYD_EXTERN NSString *HYDDestinationKeyPathKey;

@protocol HYDMapper;

@interface HYDError : NSError

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
                    sourceKey:(NSString *)sourceKey
            destinationObject:(id)destinationObject
               destinationKey:(NSString *)destinationKey
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors;

+ (instancetype)errorFromError:(HYDError *)error
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
- (id)destinationObject;
- (NSArray *)underlyingErrors;
- (NSArray *)underlyingFatalErrors;

@end
