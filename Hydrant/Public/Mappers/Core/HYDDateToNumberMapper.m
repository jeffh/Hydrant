#import "HYDDateToNumberMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDNumberToDateMapper.h"


@interface HYDDateToNumberMapper ()

@property (assign, nonatomic) HYDDateTimeUnit unit;
@property (strong, nonatomic) NSDate *sinceDate;

@end


@implementation HYDDateToNumberMapper

- (id)init
{
    return [self initWithNumericUnit:HYDDateTimeUnitSeconds sinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
}

- (id)initWithNumericUnit:(HYDDateTimeUnit)unit sinceDate:(NSDate *)sinceDate
{
    self = [super init];
    if (self) {
        self.unit = unit;
        self.sinceDate = sinceDate;
    }
    return self;
}

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    if (![sourceObject isKindOfClass:[NSDate class]]) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:nil]);
        return nil;
    }
    return @([sourceObject timeIntervalSinceDate:self.sinceDate] * (1000 / (double)self.unit));
}

- (id<HYDMapper>)reverseMapper
{
    return [[HYDNumberToDateMapper alloc] initWithNumericUnit:self.unit sinceDate:self.sinceDate];
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(void)
{
    return HYDMapDateToNumberSince1970(HYDDateTimeUnitSeconds);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(HYDDateTimeUnit unit)
{
    return HYDMapDateToNumberSince(unit, [NSDate dateWithTimeIntervalSince1970:0]);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince(NSDate *sinceDate)
{
    return HYDMapDateToNumberSince(HYDDateTimeUnitSeconds, sinceDate);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince(HYDDateTimeUnit unit, NSDate *sinceDate)
{
    return [[HYDDateToNumberMapper alloc] initWithNumericUnit:unit sinceDate:sinceDate];
}
