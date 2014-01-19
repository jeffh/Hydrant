#import "JKSCollectionMapper.h"
#import "JKSFactory.h"


@interface JKSCollectionMapper ()
@property (strong, nonatomic) Class srcItemClass;
@property (strong, nonatomic) Class dstItemClass;
@property (strong, nonatomic) Class srcCollectionClass;
@property (strong, nonatomic) Class dstCollectionClass;
@property (strong, nonatomic) id<JKSFactory> factory;
@property (weak, nonatomic) id<JKSMapper> mapper;
@end

@implementation JKSCollectionMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey
            fromItemsOfClass:(Class)srcClass
              toItemsOfClass:(Class)dstClass
       fromCollectionOfClass:(Class)srcCollectionClass
         toCollectionOfClass:(Class)dstCollectionClass
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.srcCollectionClass = srcCollectionClass;
        self.dstCollectionClass = dstCollectionClass;
        self.srcItemClass = srcClass;
        self.dstItemClass = dstClass;
    }
    return self;
}

- (id)initWithDestinationKey:(NSString *)destinationKey
            fromItemsOfClass:(Class)srcClass
              toItemsOfClass:(Class)dstClass
{
    return [self initWithDestinationKey:destinationKey
                       fromItemsOfClass:srcClass
                         toItemsOfClass:dstClass
                  fromCollectionOfClass:[NSArray class]
                    toCollectionOfClass:[NSArray class]];
}

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(NSError *__autoreleasing *)error
{
    if (!sourceObject) {
        return nil;
    }

    id collection = [self.factory newObjectOfClass:self.dstCollectionClass];

    NSUInteger index = 0;
    for (id sourceItem in sourceObject) {
        id item = [self.mapper objectFromSourceObject:sourceItem error:error];
        if (*error) {
            return nil;
        }

        if (item && ![[item class] isSubclassOfClass:self.dstItemClass]) {
            return nil;
        }

        [collection insertObject:item atIndex:index++];
    }
    return collection;
}

- (id)objectFromSourceObject:(id)sourceObject toClass:(Class)dstClass error:(NSError *__autoreleasing *)error
{
    id result = [self objectFromSourceObject:sourceObject error:error];
    if (*error) {
        return nil;
    }

    if (![sourceObject isKindOfClass:dstClass]) {
        *error = [NSError errorWithDomain:@"TODO" code:4 userInfo:nil];
        return nil;
    }
    return result;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
    self.mapper = mapper;
    self.factory = factory;
}

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[[self class] alloc] initWithDestinationKey:destinationKey
                                       fromItemsOfClass:self.dstItemClass
                                         toItemsOfClass:self.srcItemClass
                                  fromCollectionOfClass:self.dstCollectionClass
                                    toCollectionOfClass:self.srcCollectionClass];
}

@end


JKS_EXTERN
JKSCollectionMapper* JKSArrayOf(NSString *dstKey, Class srcClass, Class dstClass)
{
    return [[JKSCollectionMapper alloc] initWithDestinationKey:dstKey
                                              fromItemsOfClass:srcClass
                                                toItemsOfClass:dstClass];
}

JKS_EXTERN
JKSCollectionMapper* JKSCollection(NSString *dstKey, Class srcCollectionClass, Class srcClass, Class dstCollectionClass, Class dstClass)
{
    return [[JKSCollectionMapper alloc] initWithDestinationKey:dstKey
                                              fromItemsOfClass:srcCollectionClass
                                                toItemsOfClass:dstCollectionClass
                                         fromCollectionOfClass:srcClass
                                           toCollectionOfClass:dstClass];
}