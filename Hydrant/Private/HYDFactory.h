#import <Foundation/Foundation.h>


/*! A protocol for constructing new objects.
 *
 *  More complicated mappers want a custom way to generate new objects
 *  from a given class. This protocol allows for a generic way to do
 *  so.
 *
 *  Eventually, Hydrant-provided mappers should expose a way to
 *  set their factories. When that happens, this should be public.
 */
@protocol HYDFactory<NSObject>

- (id)newObjectOfClass:(Class)aClass;

@end
