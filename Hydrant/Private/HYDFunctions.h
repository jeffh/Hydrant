#import "HYDBase.h"


@class HYDError;
@protocol HYDAccessor;


HYD_EXTERN
void HYDSetValueForKeyIfNotNil(NSMutableDictionary *dict, id key, id value);


HYD_EXTERN
id<HYDAccessor> HYDJoinedStringFromKeyPaths(id<HYDAccessor> previousKeyPath, id<HYDAccessor> nextKeyPath);


#define HYDLocalizedStringFormat(FMT, ...) ([NSString localizedStringWithFormat:FMT, ## __VA_ARGS__])


HYD_EXTERN
void HYDSetObjectPointer(__autoreleasing id *objPtr, id value);


HYD_EXTERN
NSDictionary *HYDNormalizeKeyValueDictionary(NSDictionary *mapping, id<HYDAccessor>(^fieldFromString)(NSString *));


HYD_EXTERN
NSString *HYDPrefixSubsequentLines(NSString *prefix, NSString *raw);


HYD_EXTERN
NSString *HYDStringifyAccessor(id<HYDAccessor> accessor);
