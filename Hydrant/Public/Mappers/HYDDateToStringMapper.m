#import "HYDDateToStringMapper.h"
#import "HYDError.h"
#import "HYDStringToDateMapper.h"

@interface HYDDateToStringMapper ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation HYDDateToStringMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id value = [self.dateFormatter stringFromDate:sourceObject];

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
    return [[HYDStringToDateMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
}

@end

HYD_EXTERN
HYDDateToStringMapper *HYDDateToString(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDDateToStringWithFormatter(dstKey, dateFormatter);
}

HYD_EXTERN
HYDDateToStringMapper *HYDDateToStringWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return [[HYDDateToStringMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}