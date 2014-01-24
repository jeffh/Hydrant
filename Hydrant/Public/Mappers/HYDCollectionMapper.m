#import "HYDCollectionMapper.h"
#import "HYDFactory.h"
#import "HYDObjectFactory.h"
#import "HYDMutableCollection.h"
#import "HYDError.h"


@interface HYDCollectionMapper ()

@property (strong, nonatomic) Class sourceCollectionClass;
@property (strong, nonatomic) Class destinationCollectionClass;
@property (strong, nonatomic) id<HYDMapper> wrappedMapper;
@property (strong, nonatomic) id<HYDFactory> factory;

@end


@implementation HYDCollectionMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithItemMapper:(id<HYDMapper>)wrappedMapper sourceCollectionClass:(Class)sourceCollectionClass destinationCollectionClass:(Class)destinationCollectionClass
{
    self = [super init];
    if (self) {
        self.sourceCollectionClass = sourceCollectionClass;
        self.destinationCollectionClass = destinationCollectionClass;
        self.wrappedMapper = wrappedMapper;
        self.factory = [[HYDObjectFactory alloc] init];
    }
    return self;
}

#pragma mark - <HYDMapper>

- (NSString *)destinationKey
{
    return [self.wrappedMapper destinationKey];
}

- (id)objectFromSourceObject:(id)sourceCollection error:(__autoreleasing HYDError **)error
{
    *error = nil;
    if (!sourceCollection) {
        return nil;
    }

    if (![sourceCollection conformsToProtocol:@protocol(NSFastEnumeration)]) {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectType
                            sourceObject:sourceCollection
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
        return nil;
    }

    id<HYDMutableCollection> resultingCollection = [self.factory newObjectOfClass:self.destinationCollectionClass];

    BOOL hasFatalError = NO;
    NSMutableArray *errors = [NSMutableArray array];
    NSUInteger index = 0;
    for (id sourceObject in sourceCollection) {
        ++index;

        HYDError *itemError = nil;
        id object = [self.wrappedMapper objectFromSourceObject:sourceObject error:&itemError];

        if (itemError) {
            NSString *indexString = [NSString stringWithFormat:@"%lu", (unsigned long)(index-1)];
            [errors addObject:[HYDError errorFromError:itemError
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
        *error = [HYDError errorFromErrors:errors
                              sourceObject:sourceCollection
                                 sourceKey:nil
                         destinationObject:resultingCollection
                            destinationKey:self.destinationKey
                                   isFatal:hasFatalError];
    }

    return (hasFatalError ? nil : resultingCollection);
}

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    id<HYDMapper> reverseChildMapper = [self.wrappedMapper reverseMapperWithDestinationKey:destinationKey];
    return [[[self class] alloc] initWithItemMapper:reverseChildMapper
                              sourceCollectionClass:self.destinationCollectionClass
                         destinationCollectionClass:self.sourceCollectionClass];
}

@end


HYD_EXTERN
HYDCollectionMapper *HYDMapArrayOf(id<HYDMapper> itemMapper)
{
    return [[HYDCollectionMapper alloc] initWithItemMapper:itemMapper sourceCollectionClass:[NSArray class] destinationCollectionClass:[NSArray class]];
}
