#import "JKSCollectionMapper.h"
#import "JKSFactory.h"
#import "JKSObjectFactory.h"
#import "JKSMutableCollection.h"
#import "JKSError.h"

@interface JKSCollectionMapper ()
@property (strong, nonatomic) Class sourceCollectionClass;
@property (strong, nonatomic) Class destinationCollectionClass;
@property (strong, nonatomic) id<JKSMapper> wrappedMapper;
@property (strong, nonatomic) id<JKSFactory> factory;
@property (weak, nonatomic) id<JKSMapper> rootMapper;
@end

@implementation JKSCollectionMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithItemMapper:(id<JKSMapper>)wrappedMapper sourceCollectionClass:(Class)sourceCollectionClass destinationCollectionClass:(Class)destinationCollectionClass
{
    self = [super init];
    if (self) {
        self.sourceCollectionClass = sourceCollectionClass;
        self.destinationCollectionClass = destinationCollectionClass;
        self.wrappedMapper = wrappedMapper;
        self.factory = [[JKSObjectFactory alloc] init];
        self.rootMapper = self;
    }
    return self;
}

#pragma mark - <JKSMapper>

- (NSString *)destinationKey
{
    return [self.wrappedMapper destinationKey];
}

- (id)objectFromSourceObject:(id)sourceCollection error:(__autoreleasing JKSError **)error
{
    *error = nil;
    if (!sourceCollection) {
        return nil;
    }

    if (![sourceCollection conformsToProtocol:@protocol(NSFastEnumeration)]) {
        *error = [JKSError errorWithCode:JKSErrorInvalidSourceObjectType sourceObject:sourceCollection byMapper:self];
        return nil;
    }

    id<JKSMutableCollection> resultingCollection = [self.factory newObjectOfClass:self.destinationCollectionClass];

    [self.wrappedMapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];

    BOOL hasFatalError = NO;
    NSMutableArray *errors = [NSMutableArray array];
    NSUInteger index = 0;
    for (id sourceObject in sourceCollection) {
        ++index;

        JKSError *itemError = nil;
        id object = [self.wrappedMapper objectFromSourceObject:sourceObject error:&itemError];

        if (itemError) {
            [errors addObject:@{@"index": @(index-1),
                                @"error": itemError}];
            hasFatalError = hasFatalError || itemError.isFatal;
            continue;
        }

        [resultingCollection addObject:(object ?: [NSNull null])];
    }

    if (errors.count) {
        *error = [JKSError wrapErrors:errors
                             intoCode:(hasFatalError ?  JKSErrorInvalidSourceObjectValue : JKSErrorOptionalMappingFailed)
                         sourceObject:sourceCollection byMapper:self];
    }

    return (hasFatalError ? nil : resultingCollection);
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    id<JKSMapper> reverseChildMapper = [self.wrappedMapper reverseMapperWithDestinationKey:destinationKey];
    return [[[self class] alloc] initWithItemMapper:reverseChildMapper
                              sourceCollectionClass:self.destinationCollectionClass
                         destinationCollectionClass:self.sourceCollectionClass];
}

@end

JKS_EXTERN
JKSCollectionMapper * JKSArrayOf(id<JKSMapper> itemMapper)
{
    return [[JKSCollectionMapper alloc] initWithItemMapper:itemMapper sourceCollectionClass:[NSArray class] destinationCollectionClass:[NSArray class]];
}

JKS_EXTERN
JKSCollectionMapper * JKSSetOf(id<JKSMapper> itemMapper)
{
    return [[JKSCollectionMapper alloc] initWithItemMapper:itemMapper sourceCollectionClass:[NSSet class] destinationCollectionClass:[NSSet class]];
}