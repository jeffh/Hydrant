#import "HYDBase.h"

@class HYDError;

HYD_EXTERN
void HYDSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value);

HYD_EXTERN
NSString *HYDJoinedStringFromKeyPaths(NSString *previousKeyPath, NSString *nextKeyPath);

#define HYDLocalizedStringFormat(FMT, ...) ([NSString localizedStringWithFormat:FMT, ## __VA_ARGS__])

HYD_EXTERN
void HYDSetError(__autoreleasing HYDError **errorPtr, HYDError *error);

HYD_EXTERN
NSDictionary *HYDNormalizeKeyValueDictionary(NSDictionary *mapping);
