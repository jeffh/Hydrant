#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDTypedMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper inputClasses:(NSArray *)inputClasses outputClasses:(NSArray *)outputClasses;

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapType(NSString *destinationKey, Class expectedInputAndOutputClass);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapType(NSString *destinationKey, Class expectedInputClass, Class expectedOutputClass);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapTypes(NSString *destinationKey, NSArray *expectedInputClasses, NSArray *expectedOutputClasses);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapType(id<HYDMapper> mapperToWrap, Class expectedInputAndOutputClass);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapType(id<HYDMapper> mapperToWrap, Class expectedInputClass, Class expectedOutputClass);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapTypes(id<HYDMapper> mapperToWrap, NSArray *expectedInputClasses, NSArray *expectedOutputClasses);
