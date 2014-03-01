#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDStringToObjectFormatterMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper formatter:(NSFormatter *)formatter;

@end

#pragma mark - Base Constructor

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToObjectByFormatter(NSString *destinationKey, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToObjectByFormatter(id<HYDMapper> mapper, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - NumberFormatter Constructors

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(NSString *destinationKey);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatterStyle numberFormatterStyle);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatterStyle);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - DateFormatter Constructors

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(NSString *destinationKey, NSString *formatString);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(id<HYDMapper> mapper, NSString *formatString);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(NSString *destinationKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - URLFormatter Constructors

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURL(NSString *destinationKey);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURL(id<HYDMapper> mapper);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - UUIDFormatter Constructors

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToUUID(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToUUID(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);
