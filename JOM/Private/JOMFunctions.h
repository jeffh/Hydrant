#import "JOMBase.h"

JOM_EXTERN
void JOMSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value);

JOM_EXTERN
NSString *JOMJoinedStringFromKeyPaths(NSString *previousKeyPath, NSString *nextKeyPath);
