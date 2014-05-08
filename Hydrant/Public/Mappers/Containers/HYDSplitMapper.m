#import "HYDSplitMapper.h"


@interface HYDSplitMapper ()

@property (nonatomic, strong) id<HYDMapper> mapper;
@property (nonatomic, strong) id<HYDMapper> reverseMapper;

@end


@implementation HYDSplitMapper

- (instancetype)initWithMapper:(id<HYDMapper>)mapper reverseMapper:(id<HYDMapper>)reverseMapper
{
    self = [super init];
    if (self) {
        self.mapper = mapper;
        self.reverseMapper = reverseMapper;
    }
    return self;
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(HYDError *__autoreleasing *)error
{
    return [self.mapper objectFromSourceObject:sourceObject error:error];
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapSplit(id<HYDMapper> mapper, id<HYDMapper> reverseMapper)
{
    return [[HYDSplitMapper alloc] initWithMapper:mapper reverseMapper:reverseMapper];
}
