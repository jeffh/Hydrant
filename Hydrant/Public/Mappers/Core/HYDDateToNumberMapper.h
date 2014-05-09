#import "HYDBase.h"
#import "HYDMapper.h"
#import "HYDConstants.h"


@interface HYDDateToNumberMapper : NSObject <HYDMapper>

- (id)init;
- (id)initWithNumericUnit:(HYDNumberDateUnit)unit;

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(void);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(HYDNumberDateUnit unit);
