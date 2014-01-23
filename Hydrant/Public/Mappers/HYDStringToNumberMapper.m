#import "HYDStringToNumberMapper.h"
#import "HYDError.h"
#import "HYDNumberToStringMapper.h"


@interface HYDStringToNumberMapper ()
@property(nonatomic, strong) NSNumberFormatter *numberFormatter;
@end

@implementation HYDStringToNumberMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter
{
    self = [super init];
    if (self){
        self.destinationKey = destinationKey;
        self.numberFormatter = numberFormatter;
    }
    return self;
}

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id value = [self.numberFormatter numberFromString:[sourceObject description]];

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
    return [[HYDNumberToStringMapper alloc] initWithDestinationKey:destinationKey numberFormatter:self.numberFormatter];
}

@end

HYD_EXTERN
HYDStringToNumberMapper *HYDStringToNumber(NSString *destKey)
{
    return HYDStringToNumberByFormat(destKey, NSNumberFormatterDecimalStyle);
}

HYD_EXTERN
HYDStringToNumberMapper *HYDStringToNumberByFormat(NSString *destKey, NSNumberFormatterStyle numberFormaterStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormaterStyle;
    return [[HYDStringToNumberMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}

HYD_EXTERN
HYDStringToNumberMapper *HYDStringToNumberByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter)
{
    return [[HYDStringToNumberMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}