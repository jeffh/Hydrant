#import "HYDObjectToStringFormatterMapper.h"
#import "HYDFunctions.h"
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
        HYDSetError(error, nil);
    } else {
        HYDSetError(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                      sourceObject:sourceObject
                                         sourceKey:nil
                                 destinationObject:nil
                                    destinationKey:self.destinationKey
                                           isFatal:YES
                                  underlyingErrors:nil]);
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
HYDObjectToStringFormatterMapper *HYDMapObjectToStringByFormatter(NSString *destinationKey, NSFormatter *formatter)
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithDestinationKey:destinationKey formatter:formatter];
}

#pragma mark - NumberFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey)
{
    return HYDMapNumberToString(destinationKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return HYDMapNumberToString(destinationKey, numberFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatter *numberFormatter)
{
    return HYDMapObjectToStringByFormatter(destinationKey, numberFormatter);
}

#pragma mark - DateFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDMapDateToString(dstKey, dateFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return HYDMapObjectToStringByFormatter(dstKey, dateFormatter);
}

#pragma mark - URLFormatter Constructors

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDMapURLToString(NSString *destinationKey)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDMapObjectToStringByFormatter(destinationKey, formatter);
}


HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapObjectToStringByFormatter(destinationKey, formatter);
}
