#import "HYDNumberToStringMapper.h"
#import "HYDError.h"
#import "HYDStringToNumberMapper.h"

@interface HYDNumberToStringMapper ()
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation HYDNumberToStringMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.numberFormatter = numberFormatter;
    }
    return self;
}

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id value = [self.numberFormatter stringFromNumber:sourceObject];

    if (!value && sourceObject) {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }
    return value;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[HYDStringToNumberMapper alloc] initWithDestinationKey:destinationKey numberFormatter:self.numberFormatter];
}

@end


HYD_EXTERN
HYDNumberToStringMapper *HYDNumberToString(NSString *destKey)
{
    return HYDNumberToStringByFormat(destKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYDNumberToStringMapper *HYDNumberToStringByFormat(NSString *destKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return [[HYDNumberToStringMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}

HYD_EXTERN
HYDNumberToStringMapper *HYDNumberToStringByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return [[HYDNumberToStringMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}