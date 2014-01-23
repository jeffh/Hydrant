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
HYDObjectToStringFormatterMapper *HYDObjectToStringWithFormatter(NSString *destinationKey, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - NumberFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destinationKey);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destinationKey, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destinationKey, NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(2);


#pragma mark - DateFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - URLFormatter Constructors

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDURLToString(NSString *destinationKey);

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDURLToStringOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);