#import "HYDObjectToStringFormatterMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"
#import "HYDKeyAccessor.h"


@interface HYDObjectToStringFormatterMapper ()

@property (strong, nonatomic) NSFormatter *formatter;
@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;

@end


@implementation HYDObjectToStringFormatterMapper

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

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return [[HYDStringToObjectFormatterMapper alloc] initWithDestinationAccessor:destinationAccessor formatter:self.formatter];
}

@end

#pragma mark - Base Constructor

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDMapObjectToStringByFormatter(NSString *destinationKey, NSFormatter *formatter)
{
    return [[HYDObjectToStringFormatterMapper alloc] initWithDestinationAccessor:HYDAccessKey(destinationKey) formatter:formatter];
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

#pragma mark - UUIDFormatter Constructors

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDMapUUIDToString(NSString *destinationKey)
{
    return HYDMapObjectToStringByFormatter(destinationKey, [[HYDUUIDFormatter alloc] init]);
}
