#import "JKSBase.h"
#import "JKSMapper.h"

@interface JKSTypedMapper : NSObject <JKSMapper>

- (id)initWithMapper:(id<JKSMapper>)mapper inputClasses:(NSArray *)inputClasses outputClasses:(NSArray *)outputClasses;

@end


JKS_EXTERN
JKSTypedMapper *JKSEnforceType(id<JKSMapper> mapperToWrap, Class expectedInputClass, Class expectedOutputClass);

JKS_EXTERN
JKSTypedMapper *JKSEnforceTypes(id<JKSMapper> mapperToWrap, NSArray *expectedInputClasses, NSArray *expectedOutputClasses);