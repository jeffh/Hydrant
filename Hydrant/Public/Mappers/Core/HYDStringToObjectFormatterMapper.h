#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDStringToObjectFormatterMapper : NSObject <HYDMapper>

- (id)initWithDestinationKey:(NSString *)destinationKey formatter:(NSFormatter *)formatter;

@end

#pragma mark - Base Constructor

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDMapStringToObjectByFormatter(NSString *destinationKey, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - NumberFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *dstKey);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *dstKey, NSNumberFormatterStyle numberFormatterStyle);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *dstKey, NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - DateFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(NSString *dstKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - URLFormatter Constructors

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDMapStringToURL(NSString *destinationKey);

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDMapStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - UUIDFormatter Constructors

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDMapStringToUUID(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);
