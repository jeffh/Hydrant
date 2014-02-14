#import "HYDMapper.h"
#import "HYDError.h"

@interface HYDSFakeMapper : NSObject <HYDMapper>

@property (copy, nonatomic) NSArray *objectsToReturn;
@property (copy, nonatomic) NSArray *errorsToReturn;
@property (copy, nonatomic) NSArray *sourceObjectsReceived;

@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic) id<HYDMapper> reverseMapperToReturn;

@property (strong, nonatomic) id<HYDAccessor> reverseMapperDestinationAccessorReceived;

- (id)init;
- (id)initWithDestinationKey:(NSString *)destinationKey;
- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor;

@end
