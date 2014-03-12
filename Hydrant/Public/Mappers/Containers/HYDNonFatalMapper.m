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

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>",
            NSStringFromClass(self.class),
            self.wrappedMapper];
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDError *innerError = nil;
    id resultingObject = [self.wrappedMapper objectFromSourceObject:sourceObject error:&innerError];

    HYDSetObjectPointer(error, innerError);
    if ([innerError isFatal]){
        HYDSetObjectPointer(error, [HYDError errorFromError:innerError
                                   prependingSourceAccessor:nil
                                     andDestinationAccessor:nil
                                    replacementSourceObject:nil
                                                    isFatal:NO]);
        return self.defaultValueBlock();
    }

    return resultingObject;
}

- (id<HYDMapper>)reverseMapper
{
    id<HYDMapper> reverseWrappedMapper = [self.wrappedMapper reverseMapper];
    return [[[self class] alloc] initWithMapper:reverseWrappedMapper
                                   defaultValue:self.reverseDefaultValueBlock
                            reverseDefaultValue:self.defaultValueBlock];
}


@end


HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatally(id<HYDMapper> mapper)
{
    return HYDMapNonFatallyWithDefault(mapper, nil);
}

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefault(id<HYDMapper> mapper, id defaultValue)
{
    return HYDMapNonFatallyWithDefault(mapper, defaultValue, defaultValue);
}

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault)
{
    return [[HYDNonFatalMapper alloc] initWithMapper:mapper
                                        defaultValue:^{ return defaultValue; }
                                 reverseDefaultValue:^{ return reversedDefault; }];
}

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory)
{
    return HYDMapNonFatallyWithDefaultFactory(mapper, defaultValueFactory, defaultValueFactory);
}

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory, HYDValueBlock reversedDefaultFactory)
{
    return [[HYDNonFatalMapper alloc] initWithMapper:mapper
                                        defaultValue:defaultValueFactory
                                 reverseDefaultValue:reversedDefaultFactory];
}
