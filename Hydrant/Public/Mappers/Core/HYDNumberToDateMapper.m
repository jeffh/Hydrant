#import "HYDNumberToDateMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDDateToNumberMapper.h"


@interface HYDNumberToDateMapper ()

@property (assign, nonatomic) HYDNumberDateUnit unit;

@end


@implementation HYDNumberToDateMapper

- (id)init
{
    return [self initWithNumericUnit:HYDNumberDateUnitSeconds];
}

- (id)initWithNumericUnit:(HYDNumberDateUnit)unit
{
    self = [super init];
    if (self) {
        self.unit = unit;
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
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

- (id<HYDMapper>)reverseMapper
{
    return [[HYDDateToNumberMapper alloc] initWithNumericUnit:self.unit];
}

@end

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince1970(void)
{
    return HYDMapNumberToDateSince1970(HYDNumberDateUnitSeconds);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToDateSince1970(HYDNumberDateUnit unit)
{
    return [[HYDNumberToDateMapper alloc] initWithNumericUnit:unit];
}
