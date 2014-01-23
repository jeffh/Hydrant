#import "HYDOptionalMapper.h"
#import "HYDError.h"
#import "HYDObjectFactory.h"
#import "HYDIdentityMapper.h"


@interface HYDOptionalMapper ()

@property (strong, nonatomic) id<HYDMapper> wrappedMapper;
@property (strong, nonatomic) HYDValueBlock defaultValueBlock;
@property (strong, nonatomic) HYDValueBlock reverseDefaultValueBlock;

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
    id resultingObject = [self.wrappedMapper objectFromSourceObject:sourceObject error:error];

    if (*error){
        *error = [HYDError errorFromError:*error
                      prependingSourceKey:nil
                        andDestinationKey:nil
                  replacementSourceObject:nil
                                  isFatal:NO];
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
HYDOptionalMapper *HYDOptional(id<HYDMapper> mapper)
{
    return HYDOptionalWithDefault(mapper, nil);
}

HYD_EXTERN
HYDOptionalMapper *HYDOptionalField(NSString *destinationKey)
{
    return HYDOptional(HYDIdentity(destinationKey));
}

HYD_EXTERN
HYDOptionalMapper *HYDOptionalWithDefault(id<HYDMapper> mapper, id defaultValue)
{
    return HYDOptionalWithDefaultAndReversedDefault(mapper, defaultValue, defaultValue);
}

HYD_EXTERN
HYDOptionalMapper *HYDOptionalFieldWithDefault(NSString *destinationKey, id defaultValue)
{
    return HYDOptionalWithDefault(HYDIdentity(destinationKey), defaultValue);
}

HYD_EXTERN
HYDOptionalMapper *HYDOptionalWithDefaultAndReversedDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault)
{
    return [[HYDOptionalMapper alloc] initWithMapper:mapper
                                        defaultValue:^{ return defaultValue; }
                                 reverseDefaultValue:^{ return reversedDefault; }];
}