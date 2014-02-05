#import "HYDNonFatalMapper.h"
#import "HYDError.h"
#import "HYDObjectFactory.h"
#import "HYDIdentityMapper.h"
#import "HYDFunctions.h"


@interface HYDNonFatalMapper ()

@property (strong, nonatomic) id<HYDMapper> wrappedMapper;
@property (strong, nonatomic) HYDValueBlock defaultValueBlock;
@property (strong, nonatomic) HYDValueBlock reverseDefaultValueBlock;

@end


@implementation HYDNonFatalMapper

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

    HYDSetObjectPointer(error, innerError);
    if ([innerError isFatal]){
        HYDSetObjectPointer(error, [HYDError errorFromError:innerError
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
HYDNonFatalMapper *HYDMapNonFatally(id<HYDMapper> mapper)
{
    return HYDMapNonFatallyWithDefault(mapper, nil);
}

HYD_EXTERN
HYD_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatally(NSString *destinationKey)
{
    return HYDMapNonFatally(HYDMapIdentity(destinationKey));
}

HYD_EXTERN
HYD_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefault(id<HYDMapper> mapper, id defaultValue)
{
    return HYDMapNonFatallyWithDefaultAndReversedDefault(mapper, defaultValue, defaultValue);
}

HYD_EXTERN
HYD_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefault(NSString *destinationKey, id defaultValue)
{
    return HYDMapNonFatallyWithDefault(HYDMapIdentity(destinationKey), defaultValue);
}

HYD_EXTERN
HYDNonFatalMapper *HYDMapNonFatallyWithDefaultAndReversedDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault)
{
    return [[HYDNonFatalMapper alloc] initWithMapper:mapper
                                        defaultValue:^{ return defaultValue; }
                                 reverseDefaultValue:^{ return reversedDefault; }];
}
