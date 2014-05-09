#import "HYDDateToNumberMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDNumberToDateMapper.h"


@interface HYDDateToNumberMapper ()

@property (nonatomic) HYDNumberDateUnit unit;

@end


@implementation HYDDateToNumberMapper

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
    return @([sourceObject timeIntervalSince1970] * (1000 / (double)self.unit));
}

- (id<HYDMapper>)reverseMapper
{
    return [[HYDNumberToDateMapper alloc] initWithNumericUnit:self.unit];
}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(void)
{
    return HYDMapDateToNumberSince1970(HYDNumberDateUnitSeconds);
}

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(HYDNumberDateUnit unit)
{
    return [[HYDDateToNumberMapper alloc] initWithNumericUnit:unit];
}
