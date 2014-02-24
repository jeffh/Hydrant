#import "HYDCollectionMapper.h"
#import "HYDFactory.h"
#import "HYDObjectFactory.h"
#import "HYDCollection.h"
#import "HYDMutableCollection.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDIdentityMapper.h"
#import "HYDKeyAccessor.h"
#import "HYDObjectMapper.h"


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
    if (![sourceCollectionClass conformsToProtocol:@protocol(HYDCollection)]) {
        [NSException raise:NSInvalidArgumentException format:@"SourceCollectionClass '%@' must conform to HYDCollection protocol", sourceCollectionClass];
    }

    self = [super init];
    if (self) {
        self.sourceCollectionClass = sourceCollectionClass;
        self.destinationCollectionClass = destinationCollectionClass;
        self.wrappedMapper = wrappedMapper;
        self.factory = [[HYDObjectFactory alloc] init];
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@ -> %@ with %@>",
            NSStringFromClass(self.class),
            self.sourceCollectionClass,
            self.destinationCollectionClass,
            self.wrappedMapper];
}

#pragma mark - <HYDMapper>

- (id<HYDAccessor>)destinationAccessor
{
    return [self.wrappedMapper destinationAccessor];
}

- (id)objectFromSourceObject:(id)sourceCollection error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    if (![sourceCollection isKindOfClass:self.sourceCollectionClass]) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectType
                                              sourceObject:sourceCollection
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:self.destinationAccessor
                                                   isFatal:YES
                                          underlyingErrors:nil]);
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
                              prependingSourceAccessor:HYDAccessKey(indexString)//indexString
                                andDestinationAccessor:HYDAccessKey(indexString)//indexString
                               replacementSourceObject:sourceObject
                                               isFatal:itemError.isFatal]];
            hasFatalError = hasFatalError || itemError.isFatal;
        }

        if ([itemError isFatal] || (itemError && !object)) {
            continue;
        }

        [resultingCollection addObject:(object ?: [NSNull null])];
    }

    if (errors.count) {
        HYDSetObjectPointer(error, [HYDError errorFromErrors:errors
                                                sourceObject:sourceCollection
                                              sourceAccessor:nil
                                           destinationObject:resultingCollection
                                         destinationAccessor:self.destinationAccessor
                                                     isFatal:hasFatalError]);
    }

    return (hasFatalError ? nil : resultingCollection);
}

- (instancetype)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    id<HYDMapper> reverseChildMapper = [self.wrappedMapper reverseMapperWithDestinationAccessor:destinationAccessor];
    return [[[self class] alloc] initWithItemMapper:reverseChildMapper
                              sourceCollectionClass:self.destinationCollectionClass
                         destinationCollectionClass:self.sourceCollectionClass];
}

@end


HYD_EXTERN_OVERLOADED
HYDCollectionMapper *HYDMapCollectionOf(id<HYDMapper> itemMapper, Class sourceCollectionClass, Class destinationCollectionClass)
{
    return [[HYDCollectionMapper alloc] initWithItemMapper:itemMapper
                                     sourceCollectionClass:sourceCollectionClass
                                destinationCollectionClass:destinationCollectionClass];
}

HYD_EXTERN_OVERLOADED
HYDCollectionMapper *HYDMapCollectionOf(id<HYDMapper> itemMapper, Class collectionClass)
{
    return HYDMapCollectionOf(itemMapper, collectionClass, collectionClass);
}


HYD_EXTERN_OVERLOADED
HYDCollectionMapper *HYDMapCollectionOf(NSString *destinationKey, Class sourceCollectionClass, Class destinationCollectionClass)
{
    return HYDMapCollectionOf(HYDMapIdentity(destinationKey), sourceCollectionClass, destinationCollectionClass);
}


HYD_EXTERN_OVERLOADED
HYDCollectionMapper *HYDMapCollectionOf(NSString *destinationKey, Class collectionClass)
{
    return HYDMapCollectionOf(HYDMapIdentity(destinationKey), collectionClass, collectionClass);
}


#pragma mark - Set Constructors

HYD_EXTERN
HYDCollectionMapper *HYDMapSetOf(id<HYDMapper> itemMapper)
{
    return HYDMapCollectionOf(itemMapper, [NSSet class]);
}

#pragma mark - Array Constructors

HYD_EXTERN
HYDCollectionMapper *HYDMapArrayOf(id<HYDMapper> itemMapper)
{
    return HYDMapCollectionOf(itemMapper, [NSArray class]);
}

HYD_EXTERN_OVERLOADED
HYDCollectionMapper *HYDMapArrayOfObjects(NSString *destinationKey, Class sourceItemClass, Class destinationItemClass, NSDictionary *mapping)
{
    return HYDMapArrayOf(HYDMapObject(destinationKey, sourceItemClass, destinationItemClass, mapping));
}

HYD_EXTERN_OVERLOADED
HYDCollectionMapper *HYDMapArrayOfObjects(NSString *destinationKey, Class destinationItemClass, NSDictionary *mapping)
{
    return HYDMapArrayOf(HYDMapObject(destinationKey, destinationItemClass, mapping));
}
