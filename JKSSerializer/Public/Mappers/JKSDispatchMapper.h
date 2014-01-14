#import "JKSMapper.h"

/*! The primary "high-level" mapper.
 *
 *  This class internally stores all the serialization strategies and dispatches to the correct one given keys
 *  on the sourceObject.
 *
 *  After constructing this object, you'll define the mapping of classes for the serializer to be aware about.
 *  See `-[serializeClass:toClass:withMapping:]` and `-[serializeBetweenClass:andClass:withMapping:]`
 */
@interface JKSDispatchMapper : NSObject <JKSMapper>

/*! The object that represents a nil/null value. You can provide [NSNull null] to default to NSNull objects instead
 *  of nil. This is useful when serializing to dictionaries (which do not accept nil).
 */
@property (strong, nonatomic) id nullObject;

- (id)init;

/*! Associates a conversion from `srcClass` to `dstClass`. This is one-way.
 *
 * Mapping is a dictionary of KeyPaths of `srcClass` object properties to `dstClass` object properties.
 * Values of the map can also choose to support the `JKSFieldMapper` protocol for more flexible conversion
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
 * Values of the map can also choose to support the `JKSFieldMapper` protocol for more flexible conversion
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

@end