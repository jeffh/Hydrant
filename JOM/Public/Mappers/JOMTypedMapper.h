#import "JOMBase.h"
#import "JOMMapper.h"

@interface JOMTypedMapper : NSObject <JOMMapper>

- (id)initWithMapper:(id<JOMMapper>)mapper inputClasses:(NSArray *)inputClasses outputClasses:(NSArray *)outputClasses;

@end


JOM_EXTERN
JOMTypedMapper *JOMEnforceType(id<JOMMapper> mapperToWrap, Class expectedInputClass, Class expectedOutputClass);

JOM_EXTERN
JOMTypedMapper *JOMEnforceTypes(id<JOMMapper> mapperToWrap, NSArray *expectedInputClasses, NSArray *expectedOutputClasses);