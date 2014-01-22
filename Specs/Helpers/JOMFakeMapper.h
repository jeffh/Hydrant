#import "JOMMapper.h"
#import "JOMError.h"

@interface JOMFakeMapper : NSObject <JOMMapper>

@property (copy, nonatomic) NSArray *objectsToReturn;
@property (copy, nonatomic) NSArray *errorsToReturn;
@property (copy, nonatomic) NSArray *sourceObjectsReceived;

@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) id<JOMMapper> reverseMapperToReturn;

@property (weak, nonatomic) id<JOMMapper> rootMapperReceived;
@property (strong, nonatomic) id<JOMFactory> factoryReceived;
@property (strong, nonatomic) NSString *reverseMapperDestinationKeyReceived;

- (id)init;
- (id)initWithDestinationKey:(NSString *)destinationKey;

@end
