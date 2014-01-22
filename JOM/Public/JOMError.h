#import "JOMBase.h"

JOM_EXTERN NSString *JOMErrorDomain;
JOM_EXTERN const NSInteger JOMErrorInvalidSourceObjectValue;
JOM_EXTERN const NSInteger JOMErrorInvalidSourceObjectType;
JOM_EXTERN const NSInteger JOMErrorInvalidResultingObjectType;
JOM_EXTERN const NSInteger JOMErrorMultipleErrors;

JOM_EXTERN NSString *JOMIsFatalKey;
JOM_EXTERN NSString *JOMUnderlyingErrorsKey;
JOM_EXTERN NSString *JOMSourceObjectKey;
JOM_EXTERN NSString *JOMSourceKeyPathKey;
JOM_EXTERN NSString *JOMDestinationObjectKey;
JOM_EXTERN NSString *JOMDestinationKeyPathKey;

@protocol JOMMapper;

@interface JOMError : NSError

+ (instancetype)errorWithCode:(NSInteger)code
                 sourceObject:(id)sourceObject
                    sourceKey:(NSString *)sourceKey
            destinationObject:(id)destinationObject
               destinationKey:(NSString *)destinationKey
                      isFatal:(BOOL)isFatal
             underlyingErrors:(NSArray *)underlyingErrors;

+ (instancetype)errorFromError:(JOMError *)error
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

@end
