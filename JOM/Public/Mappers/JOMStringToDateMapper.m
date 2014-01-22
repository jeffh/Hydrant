#import "JOMStringToDateMapper.h"
#import "JOMError.h"
#import "JOMDateToStringMapper.h"


@interface JOMStringToDateMapper ()
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation JOMStringToDateMapper

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
    id value = [self.dateFormatter dateFromString:[sourceObject description]];
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

- (void)setupAsChildMapperWithMapper:(id <JOMMapper>)mapper factory:(id <JOMFactory>)factory
{
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JOMDateToStringMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
}

@end


JOM_EXTERN
JOMStringToDateMapper *JOMStringToDate(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return JOMStringToDateWithFormatter(dstKey, dateFormatter);
}

JOM_EXTERN
JOMStringToDateMapper *JOMStringToDateWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return [[JOMStringToDateMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}