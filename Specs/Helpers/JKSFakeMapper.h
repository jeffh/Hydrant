#import "JKSMapper.h"
#import "JKSError.h"

@interface JKSFakeMapper : NSObject <JKSMapper>

@property (copy, nonatomic) NSArray *objectsToReturn;
@property (copy, nonatomic) NSArray *errorsToReturn;
@property (copy, nonatomic) NSArray *sourceObjectsReceived;

@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) id<JKSMapper> reverseMapperToReturn;

@property (weak, nonatomic) id<JKSMapper> rootMapperReceived;
@property (strong, nonatomic) id<JKSFactory> factoryReceived;
@property (strong, nonatomic) NSString *reverseMapperDestinationKeyReceived;

- (id)init;
- (id)initWithDestinationKey:(NSString *)destinationKey;

@end
