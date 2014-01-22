#import "JOMDateToStringMapper.h"
#import "JOMError.h"
#import "JOMStringToDateMapper.h"

@interface JOMDateToStringMapper ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation JOMDateToStringMapper

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

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    id value = [self.dateFormatter stringFromDate:sourceObject];

    if (!value && sourceObject) {
        *error = [JOMError errorWithCode:JOMErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }
    return value;
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JOMStringToDateMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
}

@end

JOM_EXTERN
JOMDateToStringMapper *JOMDateToString(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return JOMDateToStringWithFormatter(dstKey, dateFormatter);
}

JOM_EXTERN
JOMDateToStringMapper *JOMDateToStringWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return [[JOMDateToStringMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}