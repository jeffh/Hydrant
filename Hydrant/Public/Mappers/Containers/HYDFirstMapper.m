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

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: [%@]",
            NSStringFromClass(self.class),
            [[self.mappers valueForKey:@"description"] componentsSeparatedByString:@", "]];
}

#pragma mark - HYDMapper

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
                                              sourceAccessor:nil
                                           destinationObject:nil
                                         destinationAccessor:nil
                                                     isFatal:!hasObject]);
    }

    return destinationObject;
}

- (id<HYDMapper>)reverseMapper
{
    NSMutableArray *reversedMappers = [NSMutableArray arrayWithCapacity:self.mappers.count];
    for (id<HYDMapper> mapper in self.mappers) {
        [reversedMappers addObject:[mapper reverseMapper]];
    }
    return [[[self class] alloc] initWithMappers:reversedMappers];
}

@end


HYD_EXTERN
HYDFirstMapper *HYDMapFirstMapperInArray(NSArray *mappers)
{
    return [[HYDFirstMapper alloc] initWithMappers:mappers];
}
