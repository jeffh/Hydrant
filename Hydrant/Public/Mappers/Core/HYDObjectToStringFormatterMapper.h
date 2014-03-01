#import "HYDBase.h"
#import "HYDMapper.h"

@class HYDURLFormatter;


@interface HYDObjectToStringFormatterMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper formatter:(NSFormatter *)formatter;

@end

#pragma mark - Base Constructor

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObjectToStringByFormatter(NSString *destinationKey, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObjectToStringByFormatter(id<HYDMapper> mapper, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - NumberFormatter Constructors

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(NSString *destinationKey);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper> mapper);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(NSString *destinationKey, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(NSString *destinationKey, NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper>, NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(2);


#pragma mark - DateFormatter Constructors

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(NSString *destinationKey, NSString *formatString);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(id<HYDMapper> mapper, NSString *formatString);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - URLFormatter Constructors

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapURLToString(NSString *destinationKey);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapURLToString(id<HYDMapper> mapper);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapURLToStringOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapURLToStringOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - UUIDFormatter Constructors

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapUUIDToString(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapUUIDToString(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);
