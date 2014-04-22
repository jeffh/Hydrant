#import "HYDAccessor.h"
#import "HYDKeyPathAccessor.h"

/*! Returns the default constructor for an accessor that hydrant's
 *  built-in mappers utilize when no accessor is explicitly given.
 *  (aka, NSString *destinationKey arguments).
 */
HYD_INLINE_OVERLOADED id<HYDAccessor> HYDAccessDefault(NSArray *destinationKeys)
{
    return HYDAccessKeyPathFromArray(destinationKeys);
}

/*! Returns the default constructor for an accessor that hydrant's
 *  built-in mappers utilize when no accessor is explicitly given.
 *  (aka, NSString *destinationKey arguments).
 */
HYD_INLINE_OVERLOADED id<HYDAccessor> HYDAccessDefault(NSString *destinationKey)
{
    return HYDAccessDefault(@[destinationKey]);
}
