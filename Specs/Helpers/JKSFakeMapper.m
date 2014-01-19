#import "JKSFakeMapper.h"
#import "JKSError.h"

@implementation JKSFakeMapper

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JKSError **)error
{
    self.sourceObjectReceived = sourceObject;
    *error = self.errorToReturn;
    return self.objectToReturn;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
    self.rootMapperReceived = mapper;
    self.factoryReceived = factory;
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    self.reverseMapperDestinationKeyReceived = destinationKey;
    return self.reverseMapperToReturn;
}

@end
