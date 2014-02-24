#import "HYDStringToObjectFormatterMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"
#import "HYDKeyAccessor.h"
#import "HYDIdentityMapper.h"


@interface HYDStringToObjectFormatterMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) NSFormatter *formatter;

@end


@implementation HYDStringToObjectFormatterMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)mapper formatter:(NSFormatter *)formatter
{
    self = [super init];
    if (self) {
        self.innerMapper = mapper;
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

- (id<HYDAccessor>)destinationAccessor
{
    return self.innerMapper.destinationAccessor;
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    id<HYDMapper> reverseInnerMapper = [self.innerMapper reverseMapperWithDestinationAccessor:destinationAccessor];
    return [[HYDObjectToStringFormatterMapper alloc] initWithMapper:reverseInnerMapper
                                                          formatter:self.formatter];
}

@end

#pragma mark - Base Constructor

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToObjectByFormatter(NSString *destinationKey, NSFormatter *formatter)
{
    return HYDMapStringToObjectByFormatter(HYDMapIdentity(destinationKey), formatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToObjectByFormatter(id<HYDMapper> mapper, NSFormatter *formatter)
{
    return [[HYDStringToObjectFormatterMapper alloc] initWithMapper:mapper formatter:formatter];
}

#pragma mark - NumberFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey)
{
    return HYDMapStringToNumber(destinationKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(id<HYDMapper> mapper)
{
    return HYDMapStringToNumber(mapper, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatterStyle numberFormatterStyle)
{
    return HYDMapStringToNumber(HYDMapIdentity(destinationKey), numberFormatterStyle);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatterStyle;
    return HYDMapStringToNumber(mapper, numberFormatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatter *numberFormatter)
{
    return HYDMapStringToNumber(HYDMapIdentity(destinationKey), numberFormatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)
{
    return HYDMapStringToObjectByFormatter(mapper, numberFormatter);
}

#pragma mark - DateFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(NSString *destinationKey, NSString *formatString)
{
    return HYDMapStringToDate(HYDMapIdentity(destinationKey), formatString);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(id<HYDMapper> mapper, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDMapStringToDate(mapper, dateFormatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(NSString *destinationKey, NSDateFormatter *dateFormatter)
{
    return HYDMapStringToDate(HYDMapIdentity(destinationKey), dateFormatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToDate(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
{
    return HYDMapStringToObjectByFormatter(mapper, dateFormatter);
}

#pragma mark - URLFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToURL(NSString *destinationKey)
{
    return HYDMapStringToURL(HYDMapIdentity(destinationKey));
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToURL(id<HYDMapper> mapper)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDMapStringToObjectByFormatter(mapper, formatter);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    return HYDMapStringToURLOfScheme(HYDMapIdentity(destinationKey), allowedSchemes);
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToURLOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapStringToObjectByFormatter(mapper, formatter);
}

#pragma mark - UUIDFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToUUID(NSString *destinationKey)
{
    return HYDMapStringToUUID(HYDMapIdentity(destinationKey));
}

HYD_EXTERN_OVERLOADED
HYDStringToObjectFormatterMapper *HYDMapStringToUUID(id<HYDMapper> mapper)
{
    return HYDMapStringToObjectByFormatter(mapper, [[HYDUUIDFormatter alloc] init]);
}
