#import "JOMMapper.h"
#import "JOMBase.h"

@interface JOMFirstMapper : NSObject <JOMMapper>

- (id)initWithMappers:(NSArray *)mappers;

@end

JOM_EXTERN
JOMFirstMapper *JOMFirstArray(NSArray *mappers);

#define JOMFirst(...) (JOMFirstArray(@[ __VA_ARGS__ ]))
