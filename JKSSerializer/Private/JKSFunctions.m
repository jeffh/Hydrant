#import "JKSFunctions.h"

JKS_EXTERN
void JKSSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value)
{
    if (value) {
        dict[key] = value;
    }
}

JKS_EXTERN
NSString *JKSJoinedStringFromKeyPaths(NSString *previousKeyPath, NSString *nextKeyPath)
{
    if (previousKeyPath && nextKeyPath) {
        return [NSString stringWithFormat:@"%@.%@", previousKeyPath, nextKeyPath];
    }
    return previousKeyPath ?: nextKeyPath;
}