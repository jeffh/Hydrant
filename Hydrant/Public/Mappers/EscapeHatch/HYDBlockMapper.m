#import "HYDBlockMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDAccessor.h"
#import "HYDKeyAccessor.h"

@interface HYDBlockMapper ()
@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic) HYDConversionBlock convertBlock;
@property (strong, nonatomic) HYDConversionBlock reverseConvertBlock;
@end

@implementation HYDBlockMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor convertBlock:(HYDConversionBlock)convertBlock reverseBlock:(HYDConversionBlock)reverseConvertBlock
{
    self = [super init];
    if (self) {
        self.convertBlock = convertBlock;
        self.reverseConvertBlock = reverseConvertBlock;
        self.destinationAccessor = destinationAccessor;
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

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return [[[self class] alloc] initWithDestinationAccessor:destinationAccessor
                                                convertBlock:self.reverseConvertBlock
                                                reverseBlock:self.convertBlock];
}

@end


HYD_EXTERN
HYD_OVERLOADED
HYDBlockMapper *HYDMapWithBlock(NSString *destinationKey, HYDConversionBlock convertBlock)
{
    return HYDMapWithBlock(destinationKey, convertBlock, convertBlock);
}

HYD_EXTERN
HYD_OVERLOADED
HYDBlockMapper *HYDMapWithBlock(NSString *destinationKey, HYDConversionBlock convertBlock, HYDConversionBlock reverseConvertBlock)
{
    return [[HYDBlockMapper alloc] initWithDestinationAccessor:HYDAccessKey(destinationKey)
                                                  convertBlock:convertBlock
                                                  reverseBlock:reverseConvertBlock];
}
