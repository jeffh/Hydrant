#import "HYDBlockMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"

@interface HYDBlockMapper ()
@property (copy, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) HYDConversionBlock convertBlock;
@property (strong, nonatomic) HYDConversionBlock reverseConvertBlock;
@end

@implementation HYDBlockMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey convertBlock:(HYDConversionBlock)convertBlock reverseBlock:(HYDConversionBlock)reverseConvertBlock
{
    self = [super init];
    if (self) {
        self.convertBlock = convertBlock;
        self.reverseConvertBlock = reverseConvertBlock;
        self.destinationKey = destinationKey;
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
                                                 sourceKey:blockError.sourceKey
                                         destinationObject:blockError.destinationObject
                                            destinationKey:self.destinationKey
                                                   isFatal:blockError.isFatal
                                          underlyingErrors:blockError.underlyingErrors]);
    }
    return result;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[[self class] alloc] initWithDestinationKey:destinationKey
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
    return [[HYDBlockMapper alloc] initWithDestinationKey:destinationKey convertBlock:convertBlock reverseBlock:reverseConvertBlock];
}
