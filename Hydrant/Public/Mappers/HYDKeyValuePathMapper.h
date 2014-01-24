#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDKeyValuePathMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey
                   fromClass:(Class)sourceClass
                     toClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping;

@end


/*! Constructs a mapper that maps properties from source object to a destination object
 *  using Key Value Coding (KeyPaths).
 *
 *  This essentially uses -[valueForKeyPath:] and recursive -[setValue:forKey:] to do all
 *  its mapping. All child mappers are mapped to their corresponding destinationKey
 *  they provide as the key value.
 *
 *  The destinationClass is created using [[[destinationClass alloc] init] mutableCopy]. The
 *  mutableCopy is used to ensure NSArray and NSDictionary constructors work.
 *
 *  @param destinationKey the property hint to store key value.
 *  @param sourceClass the source object type. This is used when generating a reverse mapper.
 *  @param sourceClass the destination object type. This is created by the mapper.
 *  @returns a mapper that maps properties from the source object to the destination object.
 *  @see HYDMapObject for a simular mapper, but uses keys without KeyPath.
 */
HYD_EXTERN
HYDKeyValuePathMapper *HYDMapObjectPath(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3,4);