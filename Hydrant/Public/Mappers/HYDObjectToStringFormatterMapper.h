#import "HYDBase.h"
#import "HYDMapper.h"

@class HYDURLFormatter;


@interface HYDObjectToStringFormatterMapper : NSObject <HYDMapper>
@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) NSFormatter *formatter;

- (id)initWithDestinationKey:(NSString *)destinationKey formatter:(NSFormatter *)formatter;

@end

#pragma mark - Base Constructor

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDMapObjectToStringByFormatter(NSString *destinationKey, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - NumberFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(2);


#pragma mark - DateFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - URLFormatter Constructors

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDMapURLToString(NSString *destinationKey);

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);