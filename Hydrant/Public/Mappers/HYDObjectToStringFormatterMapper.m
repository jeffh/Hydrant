#import "HYDObjectToStringFormatterMapper.h"
#import "HYDError.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDURLFormatter.h"


@implementation HYDObjectToStringFormatterMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey formatter:(NSFormatter *)formatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.formatter = formatter;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id resultingObject = nil;
    if (sourceObject) {
        resultingObject = [self.formatter stringForObjectValue:sourceObject];
    }

    if (resultingObject) {
        *error = nil;
    } else {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }
    return resultingObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[HYDStringToObjectFormatterMapper alloc] initWithDestinationKey:destinationKey formatter:self.formatter];
}

@end

#pragma mark - Base Constructor

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDObjectToStringWithFormatter(NSString *destinationKey, NSFormatter *formatter)
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithDestinationKey:destinationKey formatter:formatter];
}

#pragma mark - NumberFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destinationKey)
{
    return HYDNumberToString(destinationKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destinationKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return HYDNumberToString(destinationKey, numberFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDNumberToString(NSString *destinationKey, NSNumberFormatter *numberFormatter)
{
    return HYDObjectToStringWithFormatter(destinationKey, numberFormatter);
}

#pragma mark - DateFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDDateToString(dstKey, dateFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return HYDObjectToStringWithFormatter(dstKey, dateFormatter);
}

#pragma mark - URLFormatter Constructors

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDURLToString(NSString *destinationKey)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDStringToObjectWithFormatter(destinationKey, formatter);
}


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDURLToStringOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDStringToObjectWithFormatter(destinationKey, formatter);
}