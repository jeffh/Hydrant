#import "HYDObjectToStringFormatterMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"
#import "HYDKeyAccessor.h"
#import "HYDIdentityMapper.h"


@interface HYDObjectToStringFormatterMapper ()

@property (strong, nonatomic) NSFormatter *formatter;
@property (strong, nonatomic) id<HYDMapper> innerMapper;

@end


@implementation HYDObjectToStringFormatterMapper

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

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@ with %@>",
            NSStringFromClass(self.class),
            self.formatter,
            self.innerMapper];
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id resultingObject = nil;
    if (sourceObject) {
        resultingObject = [self.formatter stringForObjectValue:sourceObject];
    }

    if (resultingObject) {
        HYDSetObjectPointer(error, nil);
    } else {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:self.destinationAccessor
                                                   isFatal:YES
                                          underlyingErrors:nil]);
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
    return [[HYDStringToObjectFormatterMapper alloc] initWithMapper:reverseInnerMapper
                                                          formatter:self.formatter];
}

@end

#pragma mark - Base Constructor

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapObjectToStringByFormatter(NSString *destinationKey, NSFormatter *formatter)
{
    return HYDMapObjectToStringByFormatter(HYDMapIdentity(HYDAccessKey(destinationKey)), formatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapObjectToStringByFormatter(id<HYDMapper> mapper, NSFormatter *formatter)
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithMapper:mapper formatter:formatter];
}

#pragma mark - NumberFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey)
{
    return HYDMapNumberToString(destinationKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper> mapper)
{
    return HYDMapNumberToString(mapper, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatterStyle numberFormatStyle)
{
    return HYDMapNumberToString(HYDMapIdentity(destinationKey), numberFormatStyle);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return HYDMapNumberToString(mapper, numberFormatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(NSString *destinationKey, NSNumberFormatter *numberFormatter)
{
    return HYDMapNumberToString(HYDMapIdentity(destinationKey), numberFormatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)
{
    return HYDMapObjectToStringByFormatter(mapper, numberFormatter);
}

#pragma mark - DateFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *destinationKey, NSString *formatString)
{
    return HYDMapDateToString(HYDMapIdentity(destinationKey), formatString);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(id<HYDMapper> mapper, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return HYDMapDateToString(mapper, dateFormatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return HYDMapObjectToStringByFormatter(dstKey, dateFormatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapDateToString(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
{
    return HYDMapObjectToStringByFormatter(mapper, dateFormatter);
}

#pragma mark - URLFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToString(NSString *destinationKey)
{
    return HYDMapURLToString(HYDMapIdentity(destinationKey));
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToString(id<HYDMapper> mapper)
{
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] init];
    return HYDMapObjectToStringByFormatter(mapper, formatter);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
{
    return HYDMapURLToStringOfScheme(HYDMapIdentity(destinationKey), allowedSchemes);
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapURLToStringOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
{
    NSSet *schemes = [NSSet setWithArray:[allowedSchemes valueForKey:@"lowercaseString"]];
    HYDURLFormatter *formatter = [[HYDURLFormatter alloc] initWithAllowedSchemes:schemes];
    return HYDMapObjectToStringByFormatter(mapper, formatter);
}

#pragma mark - UUIDFormatter Constructors

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapUUIDToString(NSString *destinationKey)
{
    return HYDMapUUIDToString(HYDMapIdentity(destinationKey));
}

HYD_EXTERN_OVERLOADED
HYDObjectToStringFormatterMapper *HYDMapUUIDToString(id<HYDMapper> mapper)
{
    return HYDMapObjectToStringByFormatter(mapper, [[HYDUUIDFormatter alloc] init]);
}
