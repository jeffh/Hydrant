#import "HYDMapper.h"
#import "HYDError.h"

@interface HYDFakeMapper : NSObject <HYDMapper>

@property (copy, nonatomic) NSArray *objectsToReturn;
@property (copy, nonatomic) NSArray *errorsToReturn;
@property (copy, nonatomic) NSArray *sourceObjectsReceived;

@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) id<HYDMapper> reverseMapperToReturn;

@property (strong, nonatomic) NSString *reverseMapperDestinationKeyReceived;

- (id)init;
- (id)initWithDestinationKey:(NSString *)destinationKey;

@end
