#import "JKSSerializerProtocol.h"
#import "JKSMapper.h"
#import "JKSCollectionMapper.h"
#import "JKSRelationMapper.h"

/*! The public interface API to JKSSerializer.
 *
 *  This class internally stores all the serialization strategies and dispatches to the correct one given keys
 *  on the sourceObject.
 *
 *  After constructing this object, you'll define the mapping of classes for the serializer to be aware about.
 *  See `-[serializeClass:toClass:withMapping:]` and `-[serializeBetweenClass:andClass:withMapping:]`
 */
@interface JKSSerializer : NSObject <JKSSerializer>

/*! The object that represents a nil/null value. You can provide [NSNull null] to default to NSNull objects instead
 *  of nil. This is useful when serializing to dictionaries (which do not accept nil).
 */
@property (strong, nonatomic) id nullObject;

/*! A convenient shared instance to a serializer object. Use this if you prefer easier access at the cost of some testability/flexibility.
 *
 * @returns A shared instance of JKSSerializer.
 */
+ (instancetype)sharedInstance;

- (id)init;

/*! Associates a conversion from `srcClass` to `dstClass`. This is one-way.
 *
 * Mapping is a dictionary of KeyPaths of `srcClass` object properties to `dstClass` object properties.
 * Values of the map can also choose to support the `JKSMapper` protocol for more flexible conversion
 * strategies.
 *
 * @param srcClass The class of instances are being converted from.
 * @param dstClass The class of instances to produce from the `srcClass` objects.
 * @param mapping The mapping
 */
- (void)serializeClass:(Class)srcClass toClass:(Class)dstClass withMapping:(NSDictionary *)mapping;

/*! Associates a conversion from `srcClass` to `dstClass` and back. This is two-way.
 *
 * Mapping is a dictionary of KeyPaths of `srcClass` object properties to `dstClass` object properties.
 * Values of the map can also choose to support the `JKSMapper` protocol for more flexible conversion
 * strategies.
 *
 * The reverse mapping generated is the inverse of the mapping provided. If you want more flexibility,
 * use -[serializeClass:toClass:withMapping:] twice.
 *
 * @param srcClass The class of instances are being converted from.
 * @param dstClass The class of instances to produce from the `srcClass` objects.
 * @param mapping The mapping
 */
- (void)serializeBetweenClass:(Class)srcClass andClass:(Class)dstClass withMapping:(NSDictionary *)mapping;

#pragma mark <JKSSerializer>

/*! Creates a newly created object from a sourceObject using the defined class mappings.
 *
 * The returned object is dependent on the mapping defined prior to this call. The serializer
 * simply finds the first definition (in order of definition) where the sourceObject has all the keys
 * defined in the mapping.
 *
 * @param srcObject The source object to serialize
 * @returns The resulting object of a type defined by serialization mapping.
 */
- (id)objectFromObject:(id)srcObject;

/*! Creates a newly created object from a sourceObject using the specified class mapping.
 *
 * Unlike `-[objectFromObject:]` the specifically defined serialization strategy is used.
 *
 * @param dstClass The class of the object to produce after serialization.
 * @param srcObject the source object to serialize.
 * @returns An instance of `dstClass` with the serializing values of `srcObject` transferred to it.
 */
- (id)objectOfClass:(Class)dstClass fromObject:(id)srcObject;


@end