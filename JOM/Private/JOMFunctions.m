#import "JOMFunctions.h"

JOM_EXTERN
void JOMSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value)
{
    if (value) {
        dict[key] = value;
    }
}

JOM_EXTERN
NSString *JOMJoinedStringFromKeyPaths(NSString *previousKeyPath, NSString *nextKeyPath)
{
    if (previousKeyPath && nextKeyPath) {
        return [NSString stringWithFormat:@"%@.%@", previousKeyPath, nextKeyPath];
    }
    return previousKeyPath ?: nextKeyPath;
}