#import "JKSStringToDateMapper.h"
#import "JKSError.h"
#import "JKSDateToStringMapper.h"


@interface JKSStringToDateMapper ()
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation JKSStringToDateMapper

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

- (id)objectFromSourceObject:(id)sourceObject error:(NSError *__autoreleasing*)error
{
    id value = [self.dateFormatter dateFromString:[sourceObject description]];
    if (!value && sourceObject) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectValue
                                   sourceObject:sourceObject
                                       byMapper:self];
    }
    return value;
}

- (void)setupAsChildMapperWithMapper:(id <JKSMapper>)mapper factory:(id <JKSFactory>)factory
{
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JKSDateToStringMapper alloc] initWithDestinationKey:destinationKey dateFormatter:self.dateFormatter];
}

@end


JKS_EXTERN
JKSStringToDateMapper *JKSStringToDate(NSString *dstKey, NSString *formatString)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    return [[JKSStringToDateMapper alloc] initWithDestinationKey:dstKey dateFormatter:dateFormatter];
}