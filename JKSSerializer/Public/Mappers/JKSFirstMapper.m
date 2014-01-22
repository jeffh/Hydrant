#import "JKSFirstMapper.h"
#import "JKSError.h"
#import "JKSObjectFactory.h"

@interface JKSFirstMapper ()
@property (strong, nonatomic) NSArray *mappers;
@property (strong, nonatomic) id<JKSFactory> factory;
@property (weak, nonatomic) id<JKSMapper> rootMapper;
@end

@implementation JKSFirstMapper

- (id)initWithMappers:(NSArray *)mappers
{
    self = [super init];
    if (self) {
        self.mappers = mappers;
        self.factory = [[JKSObjectFactory alloc] init];
        self.rootMapper = self;
    }
    return self;
}

#pragma mark - <JKSMapper>

- (NSString *)destinationKey
{
    for (id<JKSMapper> mapper in self.mappers) {
        if ([mapper destinationKey]) {
            return [mapper destinationKey];
        }
    }
    return nil;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JKSError **)error
{
    NSMutableArray *errors = [NSMutableArray array];
    id destinationObject = nil;
    BOOL hasObject = NO;

    for (id<JKSMapper> mapper in self.mappers) {
        JKSError *childError = nil;
        [mapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];
        destinationObject = [mapper objectFromSourceObject:sourceObject error:&childError];
        if (childError) {
            [errors addObject:childError];
        }
        if (destinationObject && !childError.isFatal) {
            hasObject = YES;
            break;
        }
    }

    *error = nil;
    if (errors.count) {
        *error = [JKSError errorFromErrors:errors
                              sourceObject:sourceObject
                                 sourceKey:nil
                         destinationObject:nil
                            destinationKey:self.destinationKey
                                   isFatal:!hasObject];
    }

    return destinationObject;
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    for (id<JKSMapper> mapper in self.mappers) {
    }
    return nil;
}

@end

JKS_EXTERN
JKSFirstMapper *JKSFirstArray(NSArray *mappers)
{
    return [[JKSFirstMapper alloc] initWithMappers:mappers];
}
