#import "HYDBase.h"

HYD_EXTERN
void HYDSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value);

HYD_EXTERN
NSString *HYDJoinedStringFromKeyPaths(NSString *previousKeyPath, NSString *nextKeyPath);

#define HYDLocalizedStringFormat(FMT, ...) ([NSString localizedStringWithFormat:FMT, ## __VA_ARGS__])