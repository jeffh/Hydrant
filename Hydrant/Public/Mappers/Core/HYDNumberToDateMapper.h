#import "HYDBase.h"
#import "HYDMapper.h"
#import "HYDConstants.h"


@interface HYDNumberToDateMapper : NSObject <HYDMapper>

- (id)init;
- (id)initWithNumericUnit:(HYDNumberDateUnit)unit;

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince1970(void);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince1970(HYDNumberDateUnit unit);
