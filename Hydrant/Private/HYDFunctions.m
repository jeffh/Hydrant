#import "HYDFunctions.h"
#import "HYDNotNullMapper.h"

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
void HYDSetObjectPointer(__autoreleasing id *objPtr, id value)
{
    if (objPtr) {
        *objPtr = value;
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
            normalizedMapping[key] = HYDMapNotNull(value);
        }
    }

    return normalizedMapping;
}

HYD_EXTERN
NSString *HYDPrefixSubsequentLines(NSString *prefix, NSString *raw)
{
    NSArray *lines = [raw componentsSeparatedByString:@"\n"];
    return [lines componentsJoinedByString:[@"\n" stringByAppendingString:prefix]];
}
