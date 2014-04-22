#import "HYDBase.h"
#import <objc/runtime.h>


@class HYDError;
@protocol HYDAccessor;
@protocol HYDMapper;


#define HYDLocalizedStringFormat(FMT, ...) ([NSString localizedStringWithFormat:FMT, ## __VA_ARGS__])

HYD_EXTERN
id<HYDAccessor> HYDJoinedStringFromKeyPaths(id<HYDAccessor> previousKeyPath, id<HYDAccessor> nextKeyPath);

HYD_EXTERN
NSString *HYDKeyToString(NSString *key);

HYD_EXTERN
NSDictionary *HYDNormalizeKeyValueDictionary(NSDictionary *mapping, id<HYDAccessor>(^fieldFromString)(NSArray *));

HYD_EXTERN
NSDictionary *HYDReversedKeyValueDictionary(NSDictionary *mapping);


HYD_EXTERN
NSString *HYDPrefixSubsequentLines(NSString *prefix, NSString *raw);


HYD_EXTERN
NSString *HYDStringifyAccessor(id<HYDAccessor> accessor);


HYD_INLINE
void HYDSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value)
{
    if (value) {
        dict[key] = value;
    }
}

HYD_INLINE
void HYDSetObjectPointer(__autoreleasing id *objPtr, id value)
{
    if (objPtr) {
        *objPtr = value;
    }
}

HYD_INLINE
id HYDGetValueOrValues(NSArray *values)
{
    return values.count == 1 ? values.lastObject : values;
}

HYD_INLINE
NSArray *HYDValuesFromValueOrValues(id value)
{
    if (!value) {
        value = [NSNull null];
    }
    return [value isKindOfClass:[NSArray class]] ? value : @[value];
}

HYD_INLINE
BOOL HYDIsProtocol(id protocol)
{
    return object_getClass(protocol) == NSClassFromString(@"Protocol");
}

HYD_INLINE
BOOL HYDIsSubclassOrConformsToProtocol(id object, id classOrProtocol)
{
    return [object isKindOfClass:classOrProtocol] || (HYDIsProtocol(classOrProtocol) && [object conformsToProtocol:classOrProtocol]);
}
