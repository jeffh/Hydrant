#import "JOMMapper.h"
#import "JOMBase.h"

@class JOMObjectFactory;

typedef id(^JOMValueBlock)();

@interface JOMOptionalMapper : NSObject <JOMMapper>

- (id)initWithMapper:(id<JOMMapper>)mapper defaultValue:(JOMValueBlock)defaultValue reverseDefaultValue:(JOMValueBlock)reverseDefaultValue;

@end

JOM_EXTERN
JOMOptionalMapper *JOMOptional(id<JOMMapper> mapper);

JOM_EXTERN
JOMOptionalMapper *JOMOptionalField(NSString *destinationKey);

JOM_EXTERN
JOMOptionalMapper *JOMOptionalWithDefault(id<JOMMapper> mapper, id defaultValue);

JOM_EXTERN
JOMOptionalMapper *JOMOptionalFieldWithDefault(NSString *destinationKey, id defaultValue);

JOM_EXTERN
JOMOptionalMapper *JOMOptionalWithDefaultAndReversedDefault(id<JOMMapper> mapper, id defaultValue, id reversedDefault);
