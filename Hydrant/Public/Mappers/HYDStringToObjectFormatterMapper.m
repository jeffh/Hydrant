#import "HYDStringToObjectFormatterMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDURLFormatter.h"


@implementation HYDStringToObjectFormatterMapper

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
    BOOL success = NO;

    id resultingObject = nil;
    NSString *errorDescription = nil;

    if ([sourceObject isKindOfClass:[NSString class]]) {
        success = [self.formatter getObjectValue:&resultingObject
                                       forString:sourceObject
                                errorDescription:&errorDescription];
    }

    if (success) {
        *error = nil;
    } else {
        if (!errorDescription) {
            errorDescription = HYDLocalizedStringFormat(@"Failed to format string into object: %@", sourceObject);
        }

        NSError *originalError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:NSFormattingError
                                                 userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:@[originalError]];
        resultingObject = nil;
    }
    return resultingObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithDestinationKey:destinationKey formatter:self.formatter];
}

@end

#pragma mark - Base Constructor

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToObjectWithFormatter(NSString *destinationKey, NSFormatter *formatter)
{
    return [[HYDStringToObjectFormatterMapper alloc] initWithDestinationKey:destinationKey formatter:formatter];
}

#pragma mark - NumberFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *destKey)
{
    return HYDStringToNumber(destKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *destKey, NSNumberFormatterStyle numberFormaterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormaterStyle;
    return HYDStringToNumber(destKey, numberFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToNumber(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return HYDStringToObjectWithFormatter(destKey, numberFormatter);
}

#pragma mark - DateFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDStringToDate(dstKey, dateFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDStringToDate(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return HYDStringToObjectWithFormatter(dstKey, dateFormatter);
}

#pragma mark - URLFormatter Constructors

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToURL(NSString *destinationKey)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDStringToObjectWithFormatter(destinationKey, formatter);
}


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDStringToObjectWithFormatter(destinationKey, formatter);
}