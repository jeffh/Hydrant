#import "HYDMapper.h"
#import "HYDBase.h"


typedef void(^HYDPostProcessingBlock)(id sourceObject, id resultingObject, __autoreleasing HYDError **error);


@interface HYDPostProcessingMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper processBlock:(HYDPostProcessingBlock)block reverseProcessBlock:(HYDPostProcessingBlock)reverseBlock;

@end


HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(id<HYDMapper> mapper, HYDPostProcessingBlock block, HYDPostProcessingBlock reverseBlock);


HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(id<HYDMapper> mapper, HYDPostProcessingBlock block);


HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(NSString *destinationKey, HYDPostProcessingBlock block);
