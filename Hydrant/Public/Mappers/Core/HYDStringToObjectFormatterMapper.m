#import "HYDStringToObjectFormatterMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"
#import "HYDKeyAccessor.h"


@interface HYDStringToObjectFormatterMapper ()

@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic) NSFormatter *formatter;

@end


@implementation HYDStringToObjectFormatterMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor formatter:(NSFormatter *)formatter
{
    self = [super init];
    if (self) {
        self.destinationAccessor = destinationAccessor;
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
        HYDSetObjectPointer(error, nil);
    } else {
        if (!errorDescription) {
            errorDescription = HYDLocalizedStringFormat(@"Failed to format string into object: %@ for key '%@'",
                                                        sourceObject,
                                                        HYDStringifyAccessor(self.destinationAccessor));
        }

        NSError *originalError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:NSFormattingError
                                                 userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:self.destinationAccessor
                                                   isFatal:YES
                                          underlyingErrors:@[originalError]]);
        resultingObject = nil;
    }
    return resultingObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithDestinationAccessor:destinationAccessor formatter:self.formatter];
}

@end

#pragma mark - Base Constructor

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDMapStringToObjectByFormatter(NSString *destinationKey, NSFormatter *formatter)
{
    return [[HYDStringToObjectFormatterMapper alloc] initWithDestinationAccessor:HYDAccessKey(destinationKey) formatter:formatter];
}

#pragma mark - NumberFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey)
{
    return HYDMapStringToNumber(destinationKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatterStyle numberFormaterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormaterStyle;
    return HYDMapStringToNumber(destinationKey, numberFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatter *numberFormatter)
{
    return HYDMapStringToObjectByFormatter(destinationKey, numberFormatter);
}

#pragma mark - DateFormatter Constructors

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(NSString *destinationKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDMapStringToDate(destinationKey, dateFormatter);
}

HYD_EXTERN
HYD_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(NSString *destinationKey, NSDateFormatter *dateFormatter)
{
    return HYDMapStringToObjectByFormatter(destinationKey, dateFormatter);
}

#pragma mark - URLFormatter Constructors

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDMapStringToURL(NSString *destinationKey)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDMapStringToObjectByFormatter(destinationKey, formatter);
}


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDMapStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapStringToObjectByFormatter(destinationKey, formatter);
}

#pragma mark - UUIDFormatter Constructors

HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDMapStringToUUID(NSString *destinationKey)
{
    return HYDMapStringToObjectByFormatter(destinationKey, [[HYDUUIDFormatter alloc] init]);
}
