#import "HYDEnumMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDAccessor.h"
#import "HYDIdentityMapper.h"
#import "HYDThreadMapper.h"


@interface HYDEnumMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSDictionary *mapping;

- (id)initWithMapping:(NSDictionary *)mapping;

@end


@implementation HYDEnumMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.mapping = mapping;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>",
            NSStringFromClass(self.class),
            self.mapping];
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
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
    return [[HYDEnumMapper alloc] initWithMapping:reverseMapping];
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapEnum(NSDictionary *mapping)
{
    return [[HYDEnumMapper alloc] initWithMapping:mapping];
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapEnum(id<HYDMapper> innerMapper, NSDictionary *mapping)
{
    return HYDMapThread(innerMapper, HYDMapEnum(mapping));
}
