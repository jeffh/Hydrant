#import "HYDThreadMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"


@interface HYDThreadMapper : NSObject <HYDMapper>

@property (copy, nonatomic) NSArray *mappers;

- (instancetype)initWithMappers:(NSArray *)mappers;

@end


@implementation HYDThreadMapper

- (instancetype)initWithMappers:(NSArray *)mappers
{
    self = [super init];
    if (self) {
        self.mappers = mappers;
    }
    return self;
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id resultingObject = sourceObject;

    HYDSetObjectPointer(error, nil);

    for (id<HYDMapper> innerMapper in self.mappers) {
        HYDError *err = nil;
        resultingObject = [innerMapper objectFromSourceObject:resultingObject error:&err];

        if (err) {
            HYDSetObjectPointer(error, err);
        }

        if ([err isFatal]) {
            return nil;
        }
    }

    return resultingObject;
}

- (id<HYDMapper>)reverseMapper
{
    NSArray *reversedMappers = [[[self.mappers valueForKey:@"reverseMapper"] reverseObjectEnumerator] allObjects];
    return [[[self class] alloc] initWithMappers:reversedMappers];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>",
            NSStringFromClass([self class]),
            [[self.mappers valueForKey:@"description"] componentsJoinedByString:@" -> "]];
}

@end

HYD_EXTERN
id<HYDMapper> HYDMapThreadMappersInArray(NSArray *mappers)
{
    return [[HYDThreadMapper alloc] initWithMappers:mappers];
}
