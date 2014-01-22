#import "JKSMapper.h"
#import "JKSBase.h"

@interface JKSFirstMapper : NSObject <JKSMapper>

- (id)initWithMappers:(NSArray *)mappers;

@end

JKS_EXTERN
JKSFirstMapper *JKSFirstArray(NSArray *mappers);

#define JKSFirst(...) (JKSFirstArray(@[ __VA_ARGS__ ]))
