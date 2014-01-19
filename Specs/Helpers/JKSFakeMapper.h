#import "JKSMapper.h"
#import "JKSError.h"

@interface JKSFakeMapper : NSObject <JKSMapper>

@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) id objectToReturn;
@property (strong, nonatomic) JKSError *errorToReturn;
@property (strong, nonatomic) id<JKSMapper> reverseMapperToReturn;

@property (weak, nonatomic) id<JKSMapper> rootMapperReceived;
@property (strong, nonatomic) id<JKSFactory> factoryReceived;
@property (strong, nonatomic) id sourceObjectReceived;
@property (strong, nonatomic) NSString *reverseMapperDestinationKeyReceived;

@end
