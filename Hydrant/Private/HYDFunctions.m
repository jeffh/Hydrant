#import "HYDFunctions.h"
#import "HYDNotNullMapper.h"
#import "HYDAccessor.h"
#import "HYDKeyPathAccessor.h"

HYD_EXTERN
void HYDSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value)
{
    if (value) {
        dict[key] = value;
    }
}

HYD_EXTERN
id<HYDAccessor> HYDJoinedStringFromKeyPaths(id<HYDAccessor> previousKeyPath, id<HYDAccessor> nextKeyPath)
{
    if (previousKeyPath && nextKeyPath) {
        NSMutableArray *keyPaths = [NSMutableArray array];
        for (NSString *previousKey in previousKeyPath.fieldNames) {
            for (NSString *nextKey in nextKeyPath.fieldNames) {
                NSString *keyPath = [NSString stringWithFormat:@"%@.%@", previousKey, nextKey];
                [keyPaths addObject:keyPath];
            }
        }
        return HYDAccessKeyPathFromArray(keyPaths);
    }
    return previousKeyPath ?: nextKeyPath;
}

HYD_EXTERN
NSString *HYDKeyToString(NSString *key)
{
    if ([key rangeOfString:@"."].location != NSNotFound) {
        NSMutableString *escapedKey = [key mutableCopy];
        NSArray *replacements = @[@[@"\\", @"\\\\"],
                @[@"\"", @"\\\""]];
        for (NSArray *replacement in replacements) {
            [escapedKey replaceOccurrencesOfString:replacement.firstObject
                                        withString:replacement.lastObject
                                           options:0
                                             range:NSMakeRange(0, escapedKey.length)];
        }
        return [NSString stringWithFormat:@"\"%@\"", escapedKey];
    }
    return key;
}

HYD_EXTERN
void HYDSetObjectPointer(__autoreleasing id *objPtr, id value)
{
    if (objPtr) {
        *objPtr = value;
    }
}

HYD_EXTERN
NSDictionary *HYDNormalizeKeyValueDictionary(NSDictionary *mapping, id<HYDAccessor>(^fieldFromString)(NSString *))
{
    NSMutableDictionary *normalizedMapping = [NSMutableDictionary dictionaryWithCapacity:mapping.count];
    for (id key in mapping) {
        id<HYDAccessor> field = nil;
        id value = mapping[key];

        if ([key conformsToProtocol:@protocol(HYDAccessor)]) {
            field = key;
        } else if ([key isKindOfClass:[NSString class]]) {
            field = fieldFromString(key);
        }

        if (field) {
            if ([value conformsToProtocol:@protocol(HYDMapper)]) {
                normalizedMapping[field] = value;
            } else if ([value isKindOfClass:[NSString class]]) {
                normalizedMapping[field] = HYDMapNotNull(value);
            }
        }
    }

    return normalizedMapping;
}

HYD_EXTERN
NSDictionary *HYDReversedKeyValueDictionary(NSDictionary *mapping)
{
    NSMutableDictionary *invertedMapping = [NSMutableDictionary dictionaryWithCapacity:mapping.count];
    for (id<HYDAccessor> sourceAccessor in mapping) {
        id<HYDMapper> mapper = mapping[sourceAccessor];
        invertedMapping[mapper.destinationAccessor] = [mapper reverseMapperWithDestinationAccessor:sourceAccessor];
    }
    return invertedMapping;
}

HYD_EXTERN
NSString *HYDPrefixSubsequentLines(NSString *prefix, NSString *raw)
{
    NSArray *lines = [raw componentsSeparatedByString:@"\n"];
    return [lines componentsJoinedByString:[@"\n" stringByAppendingString:prefix]];
}

HYD_EXTERN
NSString *HYDStringifyAccessor(id<HYDAccessor> accessor)
{
    if (!accessor) {
        return @"<Unknown>";
    }

    NSArray *fieldNames = [accessor fieldNames];
    if (fieldNames.count == 1) {
        return fieldNames[0];
    } else {
        return [NSString stringWithFormat:@"[%@]", [fieldNames componentsJoinedByString:@", "]];
    }
}
