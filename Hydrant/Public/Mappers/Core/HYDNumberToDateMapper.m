#import "HYDNumberToDateMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDDateToNumberMapper.h"


@interface HYDNumberToDateMapper ()

@property (assign, nonatomic) HYDDateTimeUnit unit;
@property (strong, nonatomic) NSDate *sinceDate;

@end


@implementation HYDNumberToDateMapper

- (id)init
{
    return [self initWithNumericUnit:HYDDateTimeUnitSeconds sinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
}

- (id)initWithNumericUnit:(HYDDateTimeUnit)unit sinceDate:(NSDate *)sinceDate;
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
    if (![sourceObject isKindOfClass:[NSNumber class]]) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:nil]);
        return nil;
    }
    NSTimeInterval interval = [sourceObject doubleValue] * ((double)self.unit / 1000);
    return [NSDate dateWithTimeInterval:interval sinceDate:self.sinceDate];
}

- (id<HYDMapper>)reverseMapper
{
    return [[HYDDateToNumberMapper alloc] initWithNumericUnit:self.unit sinceDate:self.sinceDate];
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince1970(void)
{
    return HYDMapNumberToDateSince1970(HYDDateTimeUnitSeconds);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince1970(HYDDateTimeUnit unit)
{
    return HYDMapNumberToDateSince(unit, [NSDate dateWithTimeIntervalSince1970:0]);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince(NSDate *sinceDate)
{
    return HYDMapNumberToDateSince(HYDDateTimeUnitSeconds, sinceDate);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince(HYDDateTimeUnit unit, NSDate *sinceDate)
{
    return [[HYDNumberToDateMapper alloc] initWithNumericUnit:unit sinceDate:sinceDate];
}

