#import "JOMFirstMapper.h"
#import "JOMError.h"
#import "JOMObjectFactory.h"

@interface JOMFirstMapper ()
@property (strong, nonatomic) NSArray *mappers;
@property (strong, nonatomic) id<JOMFactory> factory;
@property (weak, nonatomic) id<JOMMapper> rootMapper;
@end

@implementation JOMFirstMapper

- (id)initWithMappers:(NSArray *)mappers
{
    self = [super init];
    if (self) {
        self.mappers = mappers;
        self.factory = [[JOMObjectFactory alloc] init];
        self.rootMapper = self;
    }
    return self;
}

#pragma mark - <JOMMapper>

- (NSString *)destinationKey
{
    for (id<JOMMapper> mapper in self.mappers) {
        if ([mapper destinationKey]) {
            return [mapper destinationKey];
        }
    }
    return nil;
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    NSMutableArray *errors = [NSMutableArray array];
    id destinationObject = nil;
    BOOL hasObject = NO;

    for (id<JOMMapper> mapper in self.mappers) {
        JOMError *childError = nil;
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
        *error = [JOMError errorFromErrors:errors
                              sourceObject:sourceObject
                                 sourceKey:nil
                         destinationObject:nil
                            destinationKey:self.destinationKey
                                   isFatal:!hasObject];
    }

    return destinationObject;
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    for (id<JOMMapper> mapper in self.mappers) {
    }
    return nil;
}

@end

JOM_EXTERN
JOMFirstMapper *JOMFirstArray(NSArray *mappers)
{
    return [[JOMFirstMapper alloc] initWithMappers:mappers];
}
