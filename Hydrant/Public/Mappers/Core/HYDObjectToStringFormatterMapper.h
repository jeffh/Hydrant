#import "HYDBase.h"
#import "HYDMapper.h"

@class HYDURLFormatter;


@interface HYDObjectToStringFormatterMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper formatter:(NSFormatter *)formatter;

@end

#pragma mark - Base Constructor

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapObjectToStringByFormatter(NSString *destinationKey, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapObjectToStringByFormatter(id<HYDMapper> mapper, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - NumberFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper> mapper);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper>, NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(2);


#pragma mark - DateFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *destinationKey, NSString *formatString);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(id<HYDMapper> mapper, NSString *formatString);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - URLFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToString(NSString *destinationKey);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToString(id<HYDMapper> mapper);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - UUIDFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapUUIDToString(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapUUIDToString(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);
