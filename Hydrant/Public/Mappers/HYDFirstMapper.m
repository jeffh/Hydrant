#import "HYDFirstMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"


@interface HYDFirstMapper ()

@property (strong, nonatomic) NSArray *mappers;

@end


@implementation HYDFirstMapper

- (id)initWithMappers:(NSArray *)mappers
{
    self = [super init];
    if (self) {
        self.mappers = mappers;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (NSString *)destinationKey
{
    for (id<HYDMapper> mapper in self.mappers) {
        if ([mapper destinationKey]) {
            return [mapper destinationKey];
        }
    }
    return nil;
}

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    NSMutableArray *errors = [NSMutableArray array];
    id destinationObject = nil;
    BOOL hasObject = NO;

    for (id<HYDMapper> mapper in self.mappers) {
        HYDError *childError = nil;
        destinationObject = [mapper objectFromSourceObject:sourceObject error:&childError];
        if (childError) {
            [errors addObject:childError];
        }
        if (destinationObject && !childError.isFatal) {
            hasObject = YES;
            break;
        }
    }

    HYDSetObjectPointer(error, nil);
    if (errors.count) {
        HYDSetObjectPointer(error, [HYDError errorFromErrors:errors
                                                sourceObject:sourceObject
                                                   sourceKey:nil
                                           destinationObject:nil
                                              destinationKey:self.destinationKey
                                                     isFatal:!hasObject]);
    }

    return destinationObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    NSMutableArray *reversedMappers = [NSMutableArray arrayWithCapacity:self.mappers.count];
    for (id<HYDMapper> mapper in self.mappers) {
        [reversedMappers addObject:[mapper reverseMapperWithDestinationKey:destinationKey]];
    }
    return [[[self class] alloc] initWithMappers:reversedMappers];
}

@end


HYD_EXTERN
HYDFirstMapper *HYDMapFirstMapperInArray(NSArray *mappers)
{
    return [[HYDFirstMapper alloc] initWithMappers:mappers];
}
