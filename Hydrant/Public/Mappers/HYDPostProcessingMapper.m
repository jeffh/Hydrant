#import "HYDPostProcessingMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"


@interface HYDPostProcessingMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) HYDPostProcessingBlock block;
@property (strong, nonatomic) HYDPostProcessingBlock reverseBlock;

@end


@implementation HYDPostProcessingMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)mapper processBlock:(HYDPostProcessingBlock)block reverseProcessBlock:(HYDPostProcessingBlock)reverseBlock
{
    self = [super init];
    if (self) {
        self.innerMapper = mapper;
        self.block = [block copy];
        self.reverseBlock = [reverseBlock copy];
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    HYDError *innerError = nil;
    id resultingObject = [self.innerMapper objectFromSourceObject:sourceObject error:&innerError];
    self.block(sourceObject, resultingObject, &innerError);

    HYDSetObjectPointer(error, innerError);
    if ([innerError isFatal]) {
        return nil;
    }
    return resultingObject;
}

- (NSString *)destinationKey
{
    return self.innerMapper.destinationKey;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    id<HYDMapper> reversedInnerMapper = [self.innerMapper reverseMapperWithDestinationKey:destinationKey];
    return [[[self class] alloc] initWithMapper:reversedInnerMapper
                                   processBlock:self.reverseBlock
                            reverseProcessBlock:self.block];
}

@end


HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(id<HYDMapper> mapper, HYDPostProcessingBlock block, HYDPostProcessingBlock reverseBlock)
{
    return [[HYDPostProcessingMapper alloc] initWithMapper:mapper processBlock:block reverseProcessBlock:reverseBlock];
}


HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(id<HYDMapper> mapper, HYDPostProcessingBlock block)
{
    return HYDMapWithPostProcessing(mapper, block, block);
}


HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(NSString *destinationKey, HYDPostProcessingBlock block)
{
    return HYDMapWithPostProcessing(HYDMapIdentity(destinationKey), block);
}
