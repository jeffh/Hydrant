#import "JOMCollectionMapper.h"
#import "JOMFactory.h"
#import "JOMObjectFactory.h"
#import "JOMMutableCollection.h"
#import "JOMError.h"

@interface JOMCollectionMapper ()
@property (strong, nonatomic) Class sourceCollectionClass;
@property (strong, nonatomic) Class destinationCollectionClass;
@property (strong, nonatomic) id<JOMMapper> wrappedMapper;
@property (strong, nonatomic) id<JOMFactory> factory;
@property (weak, nonatomic) id<JOMMapper> rootMapper;
@end

@implementation JOMCollectionMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithItemMapper:(id<JOMMapper>)wrappedMapper sourceCollectionClass:(Class)sourceCollectionClass destinationCollectionClass:(Class)destinationCollectionClass
{
    self = [super init];
    if (self) {
        self.sourceCollectionClass = sourceCollectionClass;
        self.destinationCollectionClass = destinationCollectionClass;
        self.wrappedMapper = wrappedMapper;
        self.factory = [[JOMObjectFactory alloc] init];
        self.rootMapper = self;
    }
    return self;
}

#pragma mark - <JOMMapper>

- (NSString *)destinationKey
{
    return [self.wrappedMapper destinationKey];
}

- (id)objectFromSourceObject:(id)sourceCollection error:(__autoreleasing JOMError **)error
{
    *error = nil;
    if (!sourceCollection) {
        return nil;
    }

    if (![sourceCollection conformsToProtocol:@protocol(NSFastEnumeration)]) {
        *error = [JOMError errorWithCode:JOMErrorInvalidSourceObjectType
                            sourceObject:sourceCollection
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
        return nil;
    }

    id<JOMMutableCollection> resultingCollection = [self.factory newObjectOfClass:self.destinationCollectionClass];

    [self.wrappedMapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];

    BOOL hasFatalError = NO;
    NSMutableArray *errors = [NSMutableArray array];
    NSUInteger index = 0;
    for (id sourceObject in sourceCollection) {
        ++index;

        JOMError *itemError = nil;
        id object = [self.wrappedMapper objectFromSourceObject:sourceObject error:&itemError];

        if (itemError) {
            NSString *indexString = [NSString stringWithFormat:@"%lu", (unsigned long)(index-1)];
            [errors addObject:[JOMError errorFromError:itemError
                                   prependingSourceKey:indexString
                                     andDestinationKey:indexString
                               replacementSourceObject:sourceObject
                                               isFatal:itemError.isFatal]];
            hasFatalError = hasFatalError || itemError.isFatal;
            continue;
        }

        [resultingCollection addObject:(object ?: [NSNull null])];
    }

    if (errors.count) {
        *error = [JOMError errorFromErrors:errors
                              sourceObject:sourceCollection
                                 sourceKey:nil
                         destinationObject:resultingCollection
                            destinationKey:self.destinationKey
                                   isFatal:hasFatalError];
    }

    return (hasFatalError ? nil : resultingCollection);
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    id<JOMMapper> reverseChildMapper = [self.wrappedMapper reverseMapperWithDestinationKey:destinationKey];
    return [[[self class] alloc] initWithItemMapper:reverseChildMapper
                              sourceCollectionClass:self.destinationCollectionClass
                         destinationCollectionClass:self.sourceCollectionClass];
}

@end

JOM_EXTERN
JOMCollectionMapper *JOMArrayOf(id<JOMMapper> itemMapper)
{
    return [[JOMCollectionMapper alloc] initWithItemMapper:itemMapper sourceCollectionClass:[NSArray class] destinationCollectionClass:[NSArray class]];
}

JOM_EXTERN
JOMCollectionMapper *JOMSetOf(id<JOMMapper> itemMapper)
{
    return [[JOMCollectionMapper alloc] initWithItemMapper:itemMapper sourceCollectionClass:[NSSet class] destinationCollectionClass:[NSSet class]];
}