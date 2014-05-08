#import "HYDEnumMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDAccessor.h"
#import "HYDKeyAccessor.h"
#import "HYDIdentityMapper.h"


@interface HYDEnumMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) NSDictionary *mapping;

@end


@implementation HYDEnumMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)mapper mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.innerMapper = mapper;
        self.mapping = mapping;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@ with %@>",
            NSStringFromClass(self.class),
            self.mapping,
            self.innerMapper];
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);

    HYDError *innerError = nil;
    sourceObject = [self.innerMapper objectFromSourceObject:sourceObject error:&innerError];
    HYDSetObjectPointer(error, innerError);

    if ([innerError isFatal]) {
        return nil;
    }

    id result = self.mapping[sourceObject];
    if (!result) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:nil]);
        return nil;
    }
    return result;
}

- (id<HYDMapper>)reverseMapper
{
    NSMutableDictionary *reverseMapping = [[NSMutableDictionary alloc] initWithCapacity:self.mapping.count];
    for (id key in self.mapping) {
        id value = self.mapping[key];
        reverseMapping[value] = key;
    }
    id<HYDMapper> reversedInnerMapper = [self.innerMapper reverseMapper];
    return [[HYDEnumMapper alloc] initWithMapper:reversedInnerMapper
                                         mapping:reverseMapping];
}

@end


HYD_EXTERN_OVERLOADED
HYDEnumMapper *HYDMapEnum(NSDictionary *mapping)
{
    return HYDMapEnum(HYDMapIdentity(), mapping);
}

HYD_EXTERN_OVERLOADED
HYDEnumMapper *HYDMapEnum(id<HYDMapper> mapper, NSDictionary *mapping)
{
    return [[HYDEnumMapper alloc] initWithMapper:mapper mapping:mapping];
}
