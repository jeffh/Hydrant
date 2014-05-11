#import "HYDFunctions.h"
#import "HYDNotNullMapper.h"
#import "HYDAccessor.h"
#import "HYDKeyPathAccessor.h"
#import "HYDMapping.h"
#import "HYDConstants.h"


HYD_EXTERN
id<HYDAccessor> HYDJoinedStringFromKeyPaths(id<HYDAccessor> previousKeyPath, id<HYDAccessor> nextKeyPath) {
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
NSString *HYDKeyToString(NSString *key) {
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
NSDictionary *HYDNormalizeKeyValueDictionary(NSDictionary *mapping, id<HYDAccessor>(^fieldFromString)(NSArray *)) {
    NSMutableDictionary *normalizedMapping = [NSMutableDictionary dictionaryWithCapacity:mapping.count];
    for (id key in mapping) {
        id<HYDAccessor> field = nil;
        id value = mapping[key];

        if ([key conformsToProtocol:@protocol(HYDAccessor)]) {
            field = key;
        } else if ([key isKindOfClass:[NSString class]]) {
            field = fieldFromString(@[key]);
        } else if ([key isKindOfClass:[NSArray class]]) {
            field = fieldFromString(key);
        }

        if (field) {
            if ([value conformsToProtocol:@protocol(HYDMapping)]) {
                normalizedMapping[field] = value;
            } else if ([value isKindOfClass:[NSArray class]]) {
                id accessor = [value lastObject];
                if ([accessor conformsToProtocol:@protocol(HYDAccessor)]) {
                    normalizedMapping[field] = HYDMap([value firstObject], (id<HYDAccessor>) accessor);
                } else if ([accessor isKindOfClass:[NSString class]]) {
                    normalizedMapping[field] = HYDMap([value firstObject], (NSString *) accessor);
                }
            } else if ([value isKindOfClass:[NSString class]]) {
                normalizedMapping[field] = HYDMap(HYDMapNotNull(), value);
            } else {
                [NSException raise:NSInvalidArgumentException
                            format:@"Unknown mapping %@ to %@; value isn't an NSArray, NSString, or HYDMapping", field, value];
            }
        }
    }

    return normalizedMapping;
}

HYD_EXTERN
NSDictionary *HYDReversedKeyValueDictionary(NSDictionary *accessorToMappingDictionary) {
    NSMutableDictionary *invertedMapping = [NSMutableDictionary dictionaryWithCapacity:accessorToMappingDictionary
            .count];
    for (id<HYDAccessor> sourceAccessor in accessorToMappingDictionary) {
        id<HYDMapping> mapping = accessorToMappingDictionary[sourceAccessor];
        invertedMapping[[mapping accessor]] = HYDMap([[mapping mapper] reverseMapper], sourceAccessor);
    }
    return invertedMapping;
}

HYD_EXTERN
NSString *HYDPrefixSubsequentLines(NSString *prefix, NSString *raw) {
    NSArray *lines = [raw componentsSeparatedByString:@"\n"];
    return [lines componentsJoinedByString:[@"\n" stringByAppendingString:prefix]];
}

HYD_EXTERN
NSString *HYDStringifyAccessor(id<HYDAccessor> accessor) {
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

HYD_EXTERN
NSError *HYDWeaklyConformsToProtocol(id object, id protocol) {
    unsigned int methodCount = 0;
    NSMutableArray *missingMethods = [NSMutableArray array];
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, YES, YES, &methodCount);
    for (NSUInteger i = 0; i < methodCount; i++) {
        struct objc_method_description method = methods[i];
        if (![object respondsToSelector:method.name]) {
            [missingMethods addObject:NSStringFromSelector(method.name)];
        }
    }

    if (missingMethods.count) {
        NSString *reason = HYDLocalizedStringFormat(@"%@ of class %@ does not weakly conform to @protocol(%@). The following methods are missing:\n - %@",
        object, [object class], NSStringFromProtocol(protocol), [missingMethods componentsJoinedByString:@"\n - "]);
        return [NSError errorWithDomain:HYDErrorDomain
                                   code:HYDErrorGenericFailure
                               userInfo:@{NSLocalizedDescriptionKey: reason}];
    }
    return nil;
}
