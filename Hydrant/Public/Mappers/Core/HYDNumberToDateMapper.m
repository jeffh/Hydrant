#import "HYDNumberToDateMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDDateToNumberMapper.h"
#import "HYDThreadMapper.h"


@interface HYDNumberToDateMapper : NSObject <HYDMapper>

@property (assign, nonatomic) HYDDateTimeUnit unit;
@property (strong, nonatomic) NSDate *sinceDate;

- (id)init;
- (id)initWithNumericUnit:(HYDDateTimeUnit)unit sinceDate:(NSDate *)sinceDate;

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
    return HYDMapDateToNumberSince(self.unit, self.sinceDate);
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

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince1970(id<HYDMapper> innerMapper)
{
    return HYDMapThread(innerMapper, HYDMapNumberToDateSince1970());
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince1970(id<HYDMapper> innerMapper, HYDDateTimeUnit unit)
{
    return HYDMapThread(innerMapper, HYDMapNumberToDateSince1970(unit));
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince(id<HYDMapper> innerMapper, NSDate *sinceDate)
{
    return HYDMapThread(innerMapper, HYDMapNumberToDateSince(sinceDate));
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince(id<HYDMapper> innerMapper, HYDDateTimeUnit unit, NSDate *sinceDate)
{
    return HYDMapThread(innerMapper, HYDMapNumberToDateSince(unit, sinceDate));
}

