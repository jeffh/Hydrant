#import "HYDStringToDateMapper.h"
#import "HYDError.h"
#import "HYDDateToStringMapper.h"


@interface HYDStringToDateMapper ()
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation HYDStringToDateMapper

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
    id value = [self.dateFormatter dateFromString:[sourceObject description]];
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
    return [[HYDDateToStringMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
}

@end


HYD_EXTERN
HYDStringToDateMapper *HYDStringToDate(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return HYDStringToDateWithFormatter(dstKey, dateFormatter);
}

HYD_EXTERN
HYDStringToDateMapper *HYDStringToDateWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return [[HYDStringToDateMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}