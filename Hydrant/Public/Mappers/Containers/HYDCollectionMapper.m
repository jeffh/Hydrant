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
#import "HYDTypedObjectMapper.h"


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

- (id)objectFromSourceObject:(id)sourceCollection error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    if (![sourceCollection isKindOfClass:self.sourceCollectionClass]) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectType
                                              sourceObject:sourceCollection
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
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
                                         destinationAccessor:nil
                                                     isFatal:hasFatalError]);
    }

    return (hasFatalError ? nil : resultingCollection);
}

- (id<HYDMapper>)reverseMapper
{
    id<HYDMapper> reverseChildMapper = [self.wrappedMapper reverseMapper];
    return [[[self class] alloc] initWithItemMapper:reverseChildMapper
                              sourceCollectionClass:self.destinationCollectionClass
                         destinationCollectionClass:self.sourceCollectionClass];
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapCollectionOf(id<HYDMapper> itemMapper, Class sourceCollectionClass, Class destinationCollectionClass)
{
    return [[HYDCollectionMapper alloc] initWithItemMapper:itemMapper
                                     sourceCollectionClass:sourceCollectionClass
                                destinationCollectionClass:destinationCollectionClass];
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapCollectionOf(id<HYDMapper> itemMapper, Class collectionClass)
{
    return HYDMapCollectionOf(itemMapper, collectionClass, collectionClass);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapCollectionOf(Class sourceCollectionClass, Class destinationCollectionClass)
{
    return HYDMapCollectionOf(HYDMapIdentity(), sourceCollectionClass, destinationCollectionClass);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapCollectionOf(Class collectionClass)
{
    return HYDMapCollectionOf(HYDMapIdentity(), collectionClass, collectionClass);
}


#pragma mark - Set Constructors

HYD_EXTERN
id<HYDMapper> HYDMapSetOf(id<HYDMapper> itemMapper)
{
    return HYDMapCollectionOf(itemMapper, [NSSet class]);
}

#pragma mark - Array Constructors

HYD_EXTERN
id<HYDMapper> HYDMapArrayOf(id<HYDMapper> itemMapper)
{
    return HYDMapCollectionOf(itemMapper, [NSArray class]);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapArrayOfKVCObjects(Class sourceItemClass, Class destinationItemClass, NSDictionary *mapping)
{
    return HYDMapArrayOf(HYDMapKVCObject(sourceItemClass, destinationItemClass, mapping));
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapArrayOfKVCObjects(Class destinationItemClass, NSDictionary *mapping)
{
    return HYDMapArrayOf(HYDMapKVCObject(destinationItemClass, mapping));
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapArrayOfObjects(Class sourceItemClass, Class destinationItemClass, NSDictionary *mapping)
{
    return HYDMapArrayOf(HYDMapObject(sourceItemClass, destinationItemClass, mapping));
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapArrayOfObjects(Class destinationItemClass, NSDictionary *mapping)
{
    return HYDMapArrayOf(HYDMapObject(destinationItemClass, mapping));
}
