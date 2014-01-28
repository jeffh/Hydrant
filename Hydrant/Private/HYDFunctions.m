#import "HYDFunctions.h"

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
