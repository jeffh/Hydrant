#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDStringToObjectFormatterMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) NSFormatter *formatter;

- (id)initWithDestinationKey:(NSString *)destinationKey formatter:(NSFormatter *)formatter;

@end

#pragma mark - Base Constructor

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToObjectWithFormatter(NSString *destinationKey, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - NumberFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *dstKey);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *dstKey, NSNumberFormatterStyle numberFormatterStyle);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *dstKey, NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - DateFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - URLFormatter Constructors

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToURL(NSString *destinationKey);

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);
