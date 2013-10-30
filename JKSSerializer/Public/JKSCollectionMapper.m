#import "JKSCollectionMapper.h"
#import "JKSSerializerProtocol.h"


@interface JKSCollectionMapper ()
@property (strong, nonatomic) Class srcItemClass;
@property (strong, nonatomic) Class dstItemClass;
@property (strong, nonatomic) Class srcCollectionClass;
@property (strong, nonatomic) Class dstCollectionClass;
@end

@implementation JKSCollectionMapper

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

- (id)objectFromSourceObject:(id)sourceObject serializer:(id<JKSSerializer>)serializer
{
    if (!sourceObject) {
        return nil;
    }

    id collection = [serializer newObjectOfClass:self.dstCollectionClass];

    NSUInteger index = 0;
    for (id item in sourceObject) {
        [collection insertObject:[serializer objectOfClass:self.dstItemClass fromObject:item]
                         atIndex:index++];
    }
    return collection;
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