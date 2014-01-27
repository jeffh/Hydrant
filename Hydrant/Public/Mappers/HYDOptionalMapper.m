#import "HYDOptionalMapper.h"
#import "HYDError.h"
#import "HYDObjectFactory.h"
#import "HYDIdentityMapper.h"
#import "HYDFunctions.h"


@interface HYDOptionalMapper ()

@property (strong, nonatomic) id<HYDMapper> wrappedMapper;
@property (strong, nonatomic) HYDValueBlock defaultValueBlock;
@property (strong, nonatomic) HYDValueBlock reverseDefaultValueBlock;
@property (strong, nonatomic) id<HYDFactory> factory;

@end


@implementation HYDOptionalMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)mapper defaultValue:(HYDValueBlock)defaultValue reverseDefaultValue:(HYDValueBlock)reverseDefaultValue
{
    self = [super init];
    if (self) {
        self.wrappedMapper = mapper;
        self.defaultValueBlock = defaultValue;
        self.reverseDefaultValueBlock = reverseDefaultValue;
        self.factory = [[HYDObjectFactory alloc] init];
    }
    return self;
}

#pragma mark - <HYDMapper>

- (NSString *)destinationKey
{
    return [self.wrappedMapper destinationKey];
}

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDError *innerError = nil;
    id resultingObject = [self.wrappedMapper objectFromSourceObject:sourceObject error:&innerError];

    HYDSetError(error, nil);
    if (innerError){
        HYDSetError(error, [HYDError errorFromError:innerError
                                prependingSourceKey:nil
                                  andDestinationKey:nil
                            replacementSourceObject:nil
                                            isFatal:NO]);
        return self.defaultValueBlock();
    }

    return resultingObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    id<HYDMapper> reverseWrappedMapper = [self.wrappedMapper reverseMapperWithDestinationKey:destinationKey];
    return [[[self class] alloc] initWithMapper:reverseWrappedMapper
                                   defaultValue:self.reverseDefaultValueBlock
                            reverseDefaultValue:self.defaultValueBlock];
}


@end


HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDMapOptionally(id<HYDMapper> mapper)
{
    return HYDMapOptionallyWithDefault(mapper, nil);
}

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDMapOptionally(NSString *destinationKey)
{
    return HYDMapOptionally(HYDMapIdentity(destinationKey));
}

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDMapOptionallyWithDefault(id<HYDMapper> mapper, id defaultValue)
{
    return HYDMapOptionallyWithDefaultAndReversedDefault(mapper, defaultValue, defaultValue);
}

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDMapOptionallyWithDefault(NSString *destinationKey, id defaultValue)
{
    return HYDMapOptionallyWithDefault(HYDMapIdentity(destinationKey), defaultValue);
}

HYD_EXTERN
HYDOptionalMapper *HYDMapOptionallyWithDefaultAndReversedDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault)
{
    return [[HYDOptionalMapper alloc] initWithMapper:mapper
                                        defaultValue:^{ return defaultValue; }
                                 reverseDefaultValue:^{ return reversedDefault; }];
}