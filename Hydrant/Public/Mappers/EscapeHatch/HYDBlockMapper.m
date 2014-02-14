#import "HYDBlockMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDAccessor.h"
#import "HYDIdentityMapper.h"

@interface HYDBlockMapper ()
@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) HYDConversionBlock convertBlock;
@property (strong, nonatomic) HYDConversionBlock reverseConvertBlock;
@end

@implementation HYDBlockMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)mapper convertBlock:(HYDConversionBlock)convertBlock reverseBlock:(HYDConversionBlock)reverseConvertBlock
{
    self = [super init];
    if (self) {
        self.convertBlock = convertBlock;
        self.reverseConvertBlock = reverseConvertBlock;
        self.innerMapper = mapper;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    HYDError *blockError = nil;
    id result = self.convertBlock(sourceObject, &blockError);
    if (blockError) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:blockError.code ?: HYDErrorInvalidSourceObjectValue
                                              sourceObject:blockError.sourceObject
                                            sourceAccessor:blockError.sourceAccessor
                                         destinationObject:blockError.destinationObject
                                       destinationAccessor:self.destinationAccessor
                                                   isFatal:blockError.isFatal
                                          underlyingErrors:blockError.underlyingErrors]);
    }
    return result;
}

- (id<HYDAccessor>)destinationAccessor
{
    return self.innerMapper.destinationAccessor;
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    id<HYDMapper> reverseInnerMapper = [self.innerMapper reverseMapperWithDestinationAccessor:destinationAccessor];
    return [[[self class] alloc] initWithMapper:reverseInnerMapper
                                   convertBlock:self.reverseConvertBlock
                                   reverseBlock:self.convertBlock];
}

@end


HYD_EXTERN_OVERLOADED
HYDBlockMapper *HYDMapWithBlock(NSString *destinationKey, HYDConversionBlock convertBlock)
{
    return HYDMapWithBlock(destinationKey, convertBlock, convertBlock);
}

HYD_EXTERN_OVERLOADED
HYDBlockMapper *HYDMapWithBlock(NSString *destinationKey, HYDConversionBlock convertBlock, HYDConversionBlock reverseConvertBlock)
{
    return [[HYDBlockMapper alloc] initWithMapper:HYDMapIdentity(destinationKey)
                                     convertBlock:convertBlock
                                     reverseBlock:reverseConvertBlock];
}
