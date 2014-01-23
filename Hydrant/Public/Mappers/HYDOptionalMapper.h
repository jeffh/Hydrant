#import "HYDMapper.h"
#import "HYDBase.h"

@class HYDObjectFactory;

typedef id(^HYDValueBlock)();

@interface HYDOptionalMapper : NSObject <HYDMapper>
@property (strong, nonatomic) id<HYDFactory> factory;

- (id)initWithMapper:(id<HYDMapper>)mapper defaultValue:(HYDValueBlock)defaultValue reverseDefaultValue:(HYDValueBlock)reverseDefaultValue;

@end

HYD_EXTERN
HYDOptionalMapper *HYDOptional(id<HYDMapper> mapper);

HYD_EXTERN
HYDOptionalMapper *HYDOptionalField(NSString *destinationKey);

HYD_EXTERN
HYDOptionalMapper *HYDOptionalWithDefault(id<HYDMapper> mapper, id defaultValue);

HYD_EXTERN
HYDOptionalMapper *HYDOptionalFieldWithDefault(NSString *destinationKey, id defaultValue);

HYD_EXTERN
HYDOptionalMapper *HYDOptionalWithDefaultAndReversedDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault);
