#import "HYDFunctions.h"
#import "HYDIdentityMapper.h"

HYD_EXTERN
void HYDSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value)
{
    if (value) {
        dict[key] = value;
    }
}

HYD_EXTERN
NSString *HYDJoinedStringFromKeyPaths(NSString *previousKeyPath, NSString *nextKeyPath)
{
    if (previousKeyPath && nextKeyPath) {
        return [NSString stringWithFormat:@"%@.%@", previousKeyPath, nextKeyPath];
    }
    return previousKeyPath ?: nextKeyPath;
}

HYD_EXTERN
void HYDSetError(__autoreleasing HYDError **errorPtr, HYDError *error)
{
    if (errorPtr) {
        *errorPtr = error;
    }
}

HYD_EXTERN
NSDictionary *HYDNormalizeKeyValueDictionary(NSDictionary *mapping)
{
    NSMutableDictionary *normalizedMapping = [NSMutableDictionary dictionaryWithCapacity:mapping.count];
    for (id key in mapping) {
        id value = mapping[key];
        if ([value conformsToProtocol:@protocol(HYDMapper)]) {
            normalizedMapping[key] = value;
        } else if ([value isKindOfClass:[NSString class]]) {
            normalizedMapping[key] = [[HYDIdentityMapper alloc] initWithDestinationKey:value];
        }
    }

    return normalizedMapping;
}
