#import "JKSBase.h"

JKS_EXTERN
void JKSSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value);

JKS_EXTERN
NSString *JKSJoinedStringFromKeyPaths(NSString *previousKeyPath, NSString *nextKeyPath);
