#import "JKSDateToStringMapper.h"
#import "JKSError.h"
#import "JKSStringToDateMapper.h"

@interface JKSDateToStringMapper ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation JKSDateToStringMapper

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

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JKSError **)error
{
    id value = [self.dateFormatter stringFromDate:sourceObject];

    if (!value && sourceObject) {
        *error = [JKSError errorWithCode:JKSErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
    }
    return value;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JKSStringToDateMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
}

@end

JKS_EXTERN
JKSDateToStringMapper *JKSDateToString(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return JKSDateToStringWithFormatter(dstKey, dateFormatter);
}

JKS_EXTERN
JKSDateToStringMapper *JKSDateToStringWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter)
{
    return [[JKSDateToStringMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}