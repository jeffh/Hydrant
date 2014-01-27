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

    HYDSetError(error, nil);
    if (errors.count) {
        HYDSetError(error, [HYDError errorFromErrors:errors
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
    for (id<HYDMapper> mapper in self.mappers) {
    }
    return nil;
}

@end


HYD_EXTERN
HYDFirstMapper *HYDMapFirstInMapperArray(NSArray *mappers)
{
    return [[HYDFirstMapper alloc] initWithMappers:mappers];
}
