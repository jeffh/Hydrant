#import "JKSMapper.h"
#import "JKSBase.h"

@class JKSObjectFactory;

@interface JKSOptionalMapper : NSObject <JKSMapper>

- (id)initWithMapper:(id<JKSMapper>)mapper defaultValue:(id)defaultValue reverseDefaultValue:(id)reverseDefaultValue;

@end

JKS_EXTERN
JKSOptionalMapper *JKSOptional(id<JKSMapper> mapper);

JKS_EXTERN
JKSOptionalMapper *JKSOptionalField(NSString *destinationKey);

JKS_EXTERN
JKSOptionalMapper *JKSOptionalWithDefault(id<JKSMapper> mapper, id defaultValue);

JKS_EXTERN
JKSOptionalMapper *JKSOptionalWithDefaultAndReversedDefault(id<JKSMapper> mapper, id defaultValue, id reversedDefault);
