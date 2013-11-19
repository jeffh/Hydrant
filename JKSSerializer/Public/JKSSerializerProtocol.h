#import <Foundation/Foundation.h>

@protocol JKSSerializer <NSObject>

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

/*! Should be used by JKSMapper-supported protocol. Produces a new instance of a given class.
 *  Ensures the object is a mutableCopy before returning it.
 *
 *  This method correctly handles receiving the immutable NSDictionary and NSArray classes and
 *  produces a NSMutableDictionary and NSMutableArray respectively.
 *
 * @param aClass The class to produce a new instance of. It may not be the class if it supports NSMutableCopying.
 * @returns A new instance of that class or the NSMutableCopying variant, if supported.
 */
- (id)newObjectOfClass:(Class)aClass;

@end