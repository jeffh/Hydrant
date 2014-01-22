#import "JOMMapper.h"
#import "JOMBase.h"

@class JOMObjectFactory;

@interface JOMOptionalMapper : NSObject <JOMMapper>

- (id)initWithMapper:(id<JOMMapper>)mapper defaultValue:(id)defaultValue reverseDefaultValue:(id)reverseDefaultValue;

@end

JOM_EXTERN
JOMOptionalMapper *JOMOptional(id<JOMMapper> mapper);

JOM_EXTERN
JOMOptionalMapper *JOMOptionalField(NSString *destinationKey);

JOM_EXTERN
JOMOptionalMapper *JOMOptionalWithDefault(id<JOMMapper> mapper, id defaultValue);

JOM_EXTERN
JOMOptionalMapper *JOMOptionalWithDefaultAndReversedDefault(id<JOMMapper> mapper, id defaultValue, id reversedDefault);
